module Wrath
class Play < GameState
  extend Forwardable

  SYNCS_PER_SECOND = 10.0 # Desired speed for sync updates.
  SYNC_DELAY = 1.0 / SYNCS_PER_SECOND
  NUM_GOATS = 5
  NUM_CHICKENS = 2
  IDEAL_PHYSICS_STEP = 1.0 / 120.0 # Physics frame-rate.

  # This is relative to the altar.
  PLAYER_SPAWNS = [[-12, 0], [12, 0]]

  # Margin in which nothing should spawn.
  module Margin
    TOP = 20
    BOTTOM = 0
    LEFT = 0
    RIGHT = 0
  end

  def_delegators :@map, :tile_at_coordinate

  attr_reader :objects, :map, :players, :network, :space, :altar, :winner

  def networked?; not @network.nil?; end
  def host?; @network.is_a? Server; end
  def client?; @network.is_a? Client; end
  def local?; @network.nil?; end
  def started?; @started; end

  # network: Server, Client, nil
  def initialize(network = nil)
    WrathObject.reset_object_ids

    @network = network

    super()

    on_input(:escape) do
      game_state_manager.pop_until_game_state Menu
    end

    on_input(:f5, :restart) unless client?

    send_message Message::NewGame.new if host?

    @last_sync = milliseconds

    init_physics

    @winner = nil
    @objects = []
    @players = []
    @started = false

    @font = Font[20]

    create_players

    unless client?
      tiles = random_tiles
      create_map(tiles)
      send_message(Message::Map.new(tiles)) if host?

      create_objects

      @started = true
    end

    send_message Message::StartGame.new if host?
  end

  def create_map(tiles)
    @map = Map.create(tiles)
  end

  def restart
    switch_game_state self.class.new(@network)
  end

  # Start the game, after sending all the init data.
  def start_game
    @started = true
  end

  def send_message(message)
    if client?
      @network.send_msg(message)
    else
      @network.broadcast_msg(message)
    end
  end

  def create_players
    log.info "Creating players"

    @players << Player.create(0, (not client?))
    @players << Player.create(1, (not host?))
  end

  def init_physics
    log.info "Initiating physics"

    @space = CP::Space.new
    @space.damping = 0

    # Wall around the play-field.
    y_margin = 16
    [
      [0, 0, 0, $window.retro_height, :left],
      [0, $window.retro_height, $window.retro_width, $window.retro_height, :bottom],
      [$window.retro_width, $window.retro_height, $window.retro_width, 0, :right],
      [$window.retro_width, y_margin, 0, y_margin, :top]
    ].each do |x1, y1, x2, y2, side|
      Wall.create(x1, y1, x2, y2, side)
    end

    # :static - An immobile object that blocks all movement.
    # :wall - Edge of the screen.
    # :object - players, mobs and carriable objects.
    # :scenery - Doesn't collide with anything at all.

    @space.on_collision(:static, [:static, :wall]) { false }
    @space.on_collision(:scenery, [:particle, :static, :object, :wall, :scenery]) { false }
    @space.on_collision(:particle, :particle) { false }
    @space.on_collision(:particle, [:static, :object, :wall]) do |particle, other|
      particle.on_collision(other)
    end

    # Objects collide with static objects, unless they are being carried or heights are different.
    @space.on_collision(:object, :static) do |a, b|
      not ((a.can_pick_up? and a.carried?) or (a.z > b.z + b.height) or (b.z > a.z + a.height))
    end

    # Objects collide with the wall, unless they are being carried.
    @space.on_collision(:object, :wall) do |object, wall|
      object.on_collision(wall)
    end

    @space.on_collision(:object, :object) do |a, b|
      # Objects only affect one another on the host/local machine.
      if client?
        false
      else
        collides = a.on_collision(b)
        collides ||= b.on_collision(a)

        collides
      end
    end
  end

  def create_objects
    log.info "Creating objects"

    # The altar is all-important!
    @altar = Altar.create(x: $window.retro_width / 2, y: ($window.retro_height + Margin::TOP) / 2)
    @objects << @altar

    # Player 1.
    player1 = Priest.create(local: true, x: altar.x + PLAYER_SPAWNS[0][0], y: altar.y + PLAYER_SPAWNS[0][1],
                            animation: "player1_8x8.png")
    @objects << player1
    players[0].avatar = player1

    # Player 2.
    player2 = Priest.create(local: @network.nil?, x: altar.x + PLAYER_SPAWNS[1][0], y: altar.y + PLAYER_SPAWNS[1][1],
                            factor_x: -1, animation: "player2_8x8.png")
    @objects << player2
    players[1].avatar = player2

    # Mobs.
    1.times { @objects << Virgin.create(spawn: true) }
    NUM_GOATS.times { @objects << Goat.create(spawn: true) }
    NUM_CHICKENS.times { @objects << Chicken.create(spawn: true) }
    1.times { @objects << Bard.create(spawn: true) }

    # Inanimate objects.
    4.times { @objects << Rock.create(spawn: true) }
    3.times { @objects << Chest.create(spawn: true, contains: [Crown, Chicken, Knight]) }
    2.times { @objects << Fire.create(spawn: true) }
    8.times { @objects << Tree.create(spawn: true) }
    5.times { @objects << Mushroom.create(spawn: true) }

    # Top "blockers", not really tangible, so don't update/sync them.
    [10, 16].each do |y|
      x = -14
      while x < $window.retro_width + 20
        Tree.create(x: x, y: rand(4) + y, paused: true)
        x += 6 + rand(6)
      end
    end
  end

  def random_tiles
    # Fill the grid with grass to start with.
    num_columns, num_rows = ($window.retro_width / Tile::WIDTH).ceil, ($window.retro_height / Tile::HEIGHT).ceil
    grid = Array.new(num_rows) { Array.new(num_columns, Grass) }

    # Add forest floor.
    num_rows.times {|i| grid[0][i] = grid[1][i] = Forest }

    # Add water-features.
    (rand(5) + 1).times do
      pos = [rand(num_columns - 4) + 2, rand(num_rows - 7) + 5]
      grid[pos[1]][pos[0]] = Water
      (rand(5) + 2).times do
        grid[pos[1] - 1 + rand(3)][pos[0] - 1 + rand(3)] = [Water, Water, Sand][rand(3)]
      end
    end

    # Put gravel under the altar.
    ((num_rows / 2)..(num_rows / 2 + 2)).each do |y|
      ((num_columns / 2 - 2)..(num_columns / 2 + 1)).each do |x|
        grid[y][x] = Gravel
      end
    end

    grid
  end

  def setup
    super
    log.info "Started playing"
  end

  def finalize
    log.info "Stopped playing"
  end

  def update
    # Read any incoming messages which will alter our start state.
    @network.update if @network

    if started?
      super

      objects.each {|o| o.update_forces }

      # Ensure that we have one or more physics steps that run at around the same interval.
      total_time = frame_time / 1000.0
      num_steps = total_time.div IDEAL_PHYSICS_STEP
      step = total_time / num_steps
      num_steps.times do
        @space.step step
      end

      # Move carried objects to appropriate positions to prevent desync in movement.
      @objects.each do |object|
        if object.respond_to?(:carrying?) and object.carrying?
          object.carrying.update_carried_position
        end
      end
    end

    # Ensure that any network objects are synced over the network.
    if @network
      sync if started?
      @network.flush
    end
  end

  def draw
    if started?
      super
    else
      @font.draw("Loading...", 0, 0, ZOrder::GUI)
    end
  end

  # A player has declared themselves the loser, so the other player wins.
  def lose!(loser)
    win!(loser.opponent)
  end

  # A player has declared themselves the winner.
  def win!(winner)
    @winner = winner
    @winner.win!
    @winner.opponent.lose!
    push_game_state GameOver.new(winner)
  end

  def sync
    if (milliseconds - @last_sync) > SYNC_DELAY
      needs_sync = objects.select {|o| o.network_sync? }
      length = send_message(Message::Sync.new(needs_sync))

      log.debug { "Synchronised #{needs_sync.size} objects in #{length} bytes" }

      @last_sync = milliseconds
    end
  end
end
end
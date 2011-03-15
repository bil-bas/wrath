module Wrath
class Play < GameState
  SYNCS_PER_SECOND = 10.0 # Desired speed for sync updates.
  SYNC_DELAY = 1.0 / SYNCS_PER_SECOND
  NUM_GOATS = 5
  NUM_CHICKENS = 2
  IDEAL_PHYSICS_STEP = 1.0 / 120.0 # Physics frame-rate.

  PLAYER_SPAWNS = [[65, 60], [95, 60]]

  attr_reader :objects, :players, :network, :tiles, :space, :altar, :winner

  def networked?; not @network.nil?; end
  def host?; @network.is_a? Server; end
  def client?; @network.is_a? Client; end
  def local?; @network.nil?; end

  # network: Server, Client, nil
  def initialize(network = nil)
    @network = network

    super()

    on_input(:escape) do
      game_state_manager.pop_until_game_state Menu
    end

    on_input(:f5) do
      switch_game_state self.class.new(@network)
    end

    send_message Message::Start.new if host?

    @last_sync = milliseconds

    init_physics

    @winner = nil
    @tiles = []
    @objects = []
    @players = []

    create_players

    unless client?
      create_tiles(random_tiles)
      create_objects
    else

    end
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

    # Player 1.
    player1 = Priest.create(local: true, x: PLAYER_SPAWNS[0][0], y: PLAYER_SPAWNS[0][1], animation: "player1_8x8.png")
    @objects << player1
    players[0].avatar = player1

    # Player 2.
    player2 = Priest.create(local: @network.nil?, x: PLAYER_SPAWNS[1][0], y: PLAYER_SPAWNS[1][1], factor_x: -1, animation: "player2_8x8.png")
    @objects << player2
    players[1].avatar = player2

    # The altar is all-important!
    @altar = Altar.create
    @objects << @altar

    # Mobs.
    1.times { @objects << Virgin.create(spawn: true) }
    NUM_GOATS.times { @objects << Goat.create(spawn: true) }
    NUM_CHICKENS.times { @objects << Chicken.create(spawn: true) }
    1.times { @objects << Bard.create(spawn: true) }

    # Inanimate objects.
    4.times { @objects << Rock.create(spawn: true) }
    3.times { @objects << Chest.create(spawn: true, contains: [Crown, Chicken, Knight]) }
    2.times { @objects << Fire.create(spawn: true) }
    4.times { @objects << Tree.create(spawn: true) }
    5.times { @objects << Mushroom.create(spawn: true) }

    # Top "blockers", not really tangible, so don't update/sync them.
    [10, 16].each do |y|
      x = -14
      while x < 180
        Tree.create(x: x, y: rand(4) + y, paused: true)
        x += 6 + rand(6)
      end
    end
  end

  def random_tiles
    # Fill the grid with grass to start with.
    grid = Array.new(20) { Array.new(20, Grass) }

    # Add forest floor.
    20.times {|i| grid[0][i] = grid[1][i] = Forest }

    # Add water-features.
    (rand(3) + 2).times do
      pos = [rand(16) + 3, rand(18) + 1]
      grid[pos[0]][pos[1]] = Water
      (rand(5) + 2).times do
        grid[pos[0] - 1 + rand(3)][pos[1] - 1 + rand(3)] = [Water, Water, Sand][rand(3)]
      end
    end

    # Put gravel under the altar.
    grid[9][9] = grid[9][10] = grid[10][9] = grid[10][10] = Gravel

    send_message(Message::Map.new(grid)) if host?

    grid
  end

  def create_tiles(tile_classes)
    log.info "Creating tiles"

    tile_classes.each_with_index do |class_row, y|
      tile_row = []
      @tiles << tile_row
      class_row.each_with_index do |type, x|
        tile_row << type.create(grid: [x, y])
      end
    end
  end

  def tile_at_coordinate(x, y)
    @tiles[y / 6.0][x / 8.0]
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

    # Ensure that any network objects are synced over the network.
    if @network
      sync
      @network.flush
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
      updates = 0
      objects.each do |object|
        if object.network_sync?
          updates += 1
          send_message(Message::Sync.new(object))
        end
      end

      log.debug { "Sent updates for #{updates} objects" }

      @last_sync = milliseconds
    end
  end
end
end
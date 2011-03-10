# encoding: utf-8

class Play < GameState
  SYNCS_PER_SECOND = 10.0 # Desired speed for sync updates.
  SYNC_DELAY = 1.0 / SYNCS_PER_SECOND
  NUM_GOATS = 5
  NUM_CHICKENS = 2

  PLAYER_SPAWNS = [[65, 60], [95, 60]]

  attr_reader :objects, :players, :network, :tiles, :space, :altar

  # network: Server, Client, nil
  def initialize(network = nil)
    @network = network

    super()

    on_input(:escape) do
      switch_game_state self.class.new(@network)
    end

    @network.broadcast_msg Message::Start.new if @network.is_a? Server

    @last_sync = milliseconds

    init_physics

    @tiles = []
    @objects = []
    @players = []
    unless @network.is_a? Client
      create_tiles(random_tiles)
      create_objects
    end
  end

  def init_physics
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
    @space.on_collision(:scenery, [:static, :object, :decal, :particle, :wall]) { false }

    @space.on_collision(:particle, [:static, :object, :wall]) do |particle, other|
      unless other.is_a? Altar
        particle.x_velocity = particle.y_velocity = 0
      end

      false
    end

    # Objects collide with static objects, unless they are being carried or heights are different.
    @space.on_collision(:object, :static) do |a, b|
      not ((a.carriable? and a.carried?) or (a.z > b.z + b.height) or (b.z > a.z + a.height))
    end

    # Objects collide with the wall, unless they are being carried.
    @space.on_collision(:object, :wall) do |object, wall|
      not (object.carriable? and object.carried?)
    end

    @space.on_collision(:object, :object) do |a, b|
      # Fire burns the player.
      [[a, b], [b, a]].each do |a, b|
        if a.is_a? Player and (b.is_a? Fire or b.is_a? Knight or b.is_a? Paladin)
          a.health -= Fire::BURN_DAMAGE * $window.dt
        end
      end

      false
    end
  end

  def finalize
    game_objects.each(&:destroy)
  end

  def create_objects
    # Player 1.
    @players << LocalPlayer.create(number: 0, local: true, x: PLAYER_SPAWNS[0][0], y: PLAYER_SPAWNS[0][1], animation: "player1_8x8.png")

    # Player 2.
    @players << LocalPlayer.create(number: 1, local: @network.nil?, x: PLAYER_SPAWNS[1][0], y: PLAYER_SPAWNS[1][1], factor_x: -1, animation: "player2_8x8.png")

    @objects = @players.dup

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

    if @network.is_a? Server
      @network.broadcast_msg(Message::Map.new(grid))
    end

    grid
  end

  def create_tiles(tile_classes)
    tile_classes.each_with_index do |row, y|
      row.each_with_index do |type, x|
        type.create(grid: [x, y])
      end
    end
  end

  def setup
    super
    puts "Started Playing"
  end

  def update
    @network.update if @network

    super

    @space.step $window.dt / 1000.0

    @players.each do |player|
      unless player.empty_handed?
        player.carrying.x, player.carrying.y = player.x, player.y
      end
    end

    if @network
      sync
      @network.flush
    end
  end

  def sync
    if (milliseconds - @last_sync) > SYNC_DELAY
      updates = 0
      objects.each do |object|
        if object.local? # object.needs_sync?
          updates += 1
          message = Message::Sync.new(object)
          if @network.is_a? Server
            @network.broadcast_msg(message)
          else
            @network.send_msg(message)
          end
        end
      end

      #puts "Sent updates for #{updates} objects"

      @last_sync = milliseconds
    end
  end
end
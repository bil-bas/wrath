# encoding: utf-8

class Play < GameState
  NUM_GOATS = 5
  NUM_CHICKENS = 2

  PLAYER_SPAWNS = [[40, 60], [120, 60]]

  attr_reader :objects, :network, :tiles

  # network: Server, Client, nil
  def initialize(network = nil)
    @network = network

    super()

    on_input(:escape) do
      switch_game_state self.class.new(@network)
    end

    @network.broadcast_msg Message::Start.new if @network.is_a? Server

    @tiles = []
    @objects = []
    unless @network.is_a? Client
      create_tiles(random_tiles)
      create_objects
    end
  end

  def finalize
    game_objects.each(&:destroy)
  end

  def create_objects
    # Player 1.
    @objects.push LocalPlayer.create(number: 0, local: true, x: PLAYER_SPAWNS[0][0], y: PLAYER_SPAWNS[0][1], animation: "player1_8x8.png")

    # Player 2.
    @objects.push LocalPlayer.create(number: 1, local: @network.nil?, x: PLAYER_SPAWNS[1][0], y: PLAYER_SPAWNS[1][1], animation: "player2_8x8.png")

    # The altar is all-important!
    @objects.push Altar.create

    # Mobs.
    @objects.push Virgin.create(spawn: true)
    @objects += Array.new(NUM_GOATS) { Goat.create(spawn: true) }
    @objects += Array.new(NUM_CHICKENS) { Chicken.create(spawn: true) }

    # Inanimate objects.
    @objects += Array.new(4) { Rock.create(spawn: true) }
    @objects += Array.new(3) { Chest.create(spawn: true, contains: [Crown, Chicken, Knight]) }
    @objects += Array.new(2) { Fire.create(spawn: true) }
  end

  def random_tiles
    # Fill the grid with grass to start with.
    grid = Array.new(20) { Array.new(20, Grass) }

    # Add water-features.
    (rand(3) + 2).times do
      pos = [rand(18) + 1, rand(18) + 1]
      grid[pos[0]][pos[1]] = Water
      (rand(5) + 2).times do
        grid[pos[0] - 1 + rand(3)][pos[1] - 1 + rand(3)] = [Water, Water, Sand][rand(3)]
      end
    end

    # Put gravel under the altar.
    grid[9][9] = grid[9][10] = grid[10][9] = grid[10][10] = Gravel

    if @network.is_a? Server
      @network.broadcast_msg(Message::Map.new(tiles: grid))
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
    puts "Started Playing"
  end

  def update
    @network.pre_update if @network
    super
    @network.post_update if @network
  end
end
# encoding: utf-8

class Play < GameState
  NUM_GOATS = 5
  NUM_CHICKENS = 2

  PLAYER_SPAWNS = [[40, 60], [120, 60]]

  attr_reader :objects, :network

  # network :server, :client, :local
  def initialize(network)
    @network = network

    super()

    on_input(:escape) { switch_game_state self.class.new(@network) }

    @background_color = Color.rgb(0, 100, 0)

    @objects = []

    # Create objects, but only if we are the host or playing a local game.
    unless @network == :client
      # Player 1.
      @objects.push LocalPlayer.create(x: PLAYER_SPAWNS[0][0], y: PLAYER_SPAWNS[0][1], animation: "player1_8x8.png", gui_pos: [10, 110],
        keys_up: [:w], keys_left: [:a], keys_right: [:d], keys_down: [:s], keys_action: [:space, :left_control, :left_shift])

      # Player 2.
      # Keys will be ignored if this is a remote player.
      player2_class = @network == :server ? RemotePlayer : LocalPlayer
      @objects.push player2_class.create(x: PLAYER_SPAWNS[1][0], y: PLAYER_SPAWNS[1][1], animation: "player2_8x8.png", gui_pos: [100, 110],
        keys_up: [:up], keys_left: [:left], keys_right: [:right], keys_down: [:down], keys_action: [:right_control, :right_shift, :enter])

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
  end

  def setup
    puts "Started Playing"
  end

  def update
    previous_game_state.update unless @network == :local
    super
  end

  def draw
    $window.pixel.draw 0, 0, ZOrder::BACKGROUND, $window.width, $window.height, @background_color
    super
  end
end
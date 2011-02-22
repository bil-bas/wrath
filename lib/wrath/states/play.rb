# encoding: utf-8

class Play < GameState
  NUM_GOATS = 5
  NUM_CHICKENS = 2

  attr_reader :mobs, :altar

  def initialize(socket = nil)
    super

    @local_player = LocalPlayer.create(x: 40, y: 60, image_row: 0, gui_pos: [10, 110],
      keys_up: [:w], keys_left: [:a], keys_right: [:d], keys_down: [:s], keys_action: [:space, :left_control, :left_shift])

    @remote_player = LocalPlayer.create(x: 120, y: 60, image_row: 1, gui_pos: [100, 110],
      keys_up: [:up], keys_left: [:left], keys_right: [:right], keys_down: [:down], keys_action: [:right_control, :right_shift, :enter])

    @altar = Altar.create
    @background_color = Color.rgb(0, 100, 0)

    @mobs = []
    @mobs.push Virgin.create(spawn: true)
    @mobs += Array.new(NUM_GOATS) { Goat.create(spawn: true) }
    @mobs += Array.new(NUM_CHICKENS) { Chicken.create(spawn: true) }
    @mobs += Array.new(4) { Rock.create(spawn: true) }
    @mobs += Array.new(3) { Chest.create(spawn: true, contains: [Crown, Chicken, Knight]) }
    @mobs += [Fire.create(x: 20, y: 60), Fire.create(x: 140, y: 60)]


    on_input(:escape) { switch_game_state self.class }
  end

  def setup
    puts "Started Playing"
  end

  def draw
    $window.pixel.draw 0, 0, ZOrder::BACKGROUND, $window.width, $window.height, @background_color
    super
  end
end
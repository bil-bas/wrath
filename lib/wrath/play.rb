# encoding: utf-8

class Play < GameState
  NUM_GOATS = 5

  attr_reader :goats, :altar

  def setup
    @local_player = LocalPlayer.create(x: 40, y: 60)
    @remote_player = Player.create(x: 120, y: 60)

    @altar = Altar.create
    @background_color = Color.rgb(0, 100, 0)

    @goats = Array.new(NUM_GOATS) { Goat.create(:spawn => true) }
  end

  def draw
    $window.pixel.draw 0, 0, ZOrder::BACKGROUND, $window.width, $window.height, @background_color
    super
  end
end
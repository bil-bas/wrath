module Wrath
class Menu < Gui
  def initialize
    super

    add_inputs(
        p: Play,
        i: Instructions,
        a: ViewAchievements,
        o: Options,
        x: :close,
        escape: :close
    )

    Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

    create_background

    pack :horizontal, padding_left: 30, padding_top: 0, spacing: 0 do
      @left_priests = pack :vertical, padding_top: 12, padding_left: 0, padding_right: 0, spacing: 14

      pack :vertical, spacing: 0, padding: 0 do
        heading = label "Wrath", font_size: 120, color: Color.rgb(50, 120, 255), width: 500, justify: :center
        label "Appease or Die!", font_size: 40, color: Color.rgb(90, 180, 255), width: heading.width, padding_top: 0, justify: :center
        pack :vertical, spacing: 8, padding_top: 30, padding_left: 80 do
          options = { width: heading.width - 15 - 160, font_size: 28, justify: :center }
          button("(P)lay", options.merge(tip: 'Play the game, on- or off-line')) { push_game_state Play }
          button("(I)nstructions", options.merge(tip: 'Learn how to play the game')) { push_game_state Instructions }
          button("(A)chievements", options.merge(tip: 'Review your achievements')) { push_game_state ViewAchievements }
          button("(O)ptions", options.merge(tip: "View and change game settings")) { push_game_state Options }
          button("E(x)it", options) { close }
        end

        label "v#{VERSION}", font_size: 18, justify: :center, width: heading.width
      end

      @right_priests = pack :vertical, padding_top: 12, padding_left: 0, padding_right: 0, spacing: 14
    end
  end

  def create_background
    @background_image = TexPlay.create_image($window, $window.retro_width, $window.retro_height, color: Color.rgb(0, 0, 40))
    500.times do
      @background_image.set_pixel(rand($window.retro_width), rand($window.retro_height),
                                  color: Color.rgba(255, 255, 255, 150 + rand(50)))
    end
  end

  def draw
    @background_image.draw 0, 0, 0
    super
  end

  def setup
    super

    icons = Priest::NAMES.map {|name| ScaledImage.new(Priest.icon(name), $window.sprite_scale * 3) }
    @left_priests.clear
    @left_priests.with do
      icons[0..3].each_with_index {|icon, i| label '', icon: icon, tip: Priest.title(Priest::NAMES[i]) }
    end

    @right_priests.clear
    @right_priests.with do
       icons[4..7].each_with_index {|icon, i| label '', icon: icon, tip: Priest.title(Priest::NAMES[i + 4]) }
    end

    log.info "Viewing main menu"
  end

  def close
    log.info "Exited game"
    super
    exit
  end
end
end

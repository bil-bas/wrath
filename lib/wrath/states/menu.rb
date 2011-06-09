module Wrath
class Menu < Gui
  ACTIONS = {
    play: Play,
    instructions: Instructions,
    achievements: ViewAchievements,
    options: Options,
    exit: :close,
  }

  def initialize
    super

    Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

    create_background

    horizontal padding_left: ($window.width - 680) / 2, padding_top: ($window.height - 475) / 2, spacing: 0 do
      @left_priests = vertical padding_top: 15, padding_left: 0, padding_right: 0, spacing: 14
      vertical spacing: 0, padding: 0 do
        heading = label t.title, font_size: 120, color: Color.rgb(50, 120, 255), width: 500, justify: :center
        label t.subtitle, font_size: 40, color: Color.rgb(90, 180, 255), width: heading.width, padding_top: 0, justify: :center
        vertical spacing: 8, padding_top: 30, padding_left: 80 do
          options = { width: heading.width - 15 - 160, font_size: 28, justify: :center, shortcut: true }
          ACTIONS.each_pair do |name, action|
            button(t.button[name].text, options.merge(tip: t.button[name].tip)) do
              case action
                when Class then push_game_state(action)
                when Symbol then send(action)
              end
            end
          end
        end

        label "v#{VERSION}", font_size: 18, justify: :center, width: heading.width
      end

      @right_priests = vertical padding_top: 15, padding_left: 0, padding_right: 0, spacing: 14
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

    icons = Priest::NAMES.map {|name| ScaledImage.new(Priest.icon(name), 9) }
    @left_priests.clear
    @left_priests.with do
      icons[0..4].each_with_index {|icon, i| label '', icon: icon, tip: Priest.title(Priest::NAMES[i]) }
    end

    @right_priests.clear
    @right_priests.with do
       icons[5..9].each_with_index {|icon, i| label '', icon: icon, tip: Priest.title(Priest::NAMES[i + 5]) }
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

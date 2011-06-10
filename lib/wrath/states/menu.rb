module Wrath
class Menu < Gui
  ACTIONS = {
    play: Play,
    instructions: Instructions,
    achievements: ViewAchievements,
    options: Options,
    exit: :close,
  }

  def setup
    super

    Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

    horizontal spacing: 0, align: :center do
      @left_priests = vertical padding: 0, spacing: 14
      vertical spacing: 0, padding: 0 do
        label t.title, font_size: 120, color: Color.rgb(50, 120, 255), width: 500, justify: :center
        label t.subtitle, font_size: 40, color: Color.rgb(90, 180, 255), align: :center, padding_top: 0, justify: :center
        vertical spacing: 8, align: :center do
          options = { width: 300, font_size: 28, justify: :center, shortcut: :auto }
          ACTIONS.each_pair do |name, action|
            button(t.button[name].text, options.merge(tip: t.button[name].tip)) do
              case action
                when Class then push_game_state(action)
                when Symbol then send(action)
              end
            end
          end
        end

        label "v#{VERSION}", font_size: 18, justify: :center, align: :center
      end

      @right_priests = vertical padding: 0, spacing: 14
    end

    icons = Priest::NAMES.map {|name| ScaledImage.new(Priest.icon(name), $window.sprite_scale * 2.3) }
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

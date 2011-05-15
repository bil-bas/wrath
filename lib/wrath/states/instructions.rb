module Wrath
  class Instructions < Gui
    HOW_TO_PLAY = File.join(File.dirname(__FILE__), 'instructions.yml')

    def initialize
      super

      on_input(:escape, :pop_game_state)

      pack :vertical, padding: 20 do
        label "Instructions for Wrath: Appease or Die!", font_size: 24
        how_to_play = YAML.load(File.read(HOW_TO_PLAY))

        pack :vertical, spacing: 0, padding: 0 do
          how_to_play.each do |text|
            case text[:type]
              when :title
                label text[:body]
              when :block
                text_area text: text[:body], font_size: 15, padding_h: 10, enabled: false, width: $window.width - 50
            end
          end
        end

        button("Back") { pop_game_state }
      end
    end


  end
end
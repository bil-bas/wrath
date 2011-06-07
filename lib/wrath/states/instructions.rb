module Wrath
  class Instructions < Gui
    HOW_TO_PLAY = File.join(File.dirname(__FILE__), 'instructions.yml')

    def initialize
      super

      on_input([:escape, :b], :pop_game_state)

      vertical do
        label "Instructions", font_size: 32

        @how_to_play = YAML.load(File.read(HOW_TO_PLAY))

        Gosu::register_entity(:bullet, Image['gui/bullet.png'])

        vertical spacing: 0, padding: 0 do
          @tabs_group = group do
            @tab_buttons = horizontal padding: 0, spacing: 5 do
              @how_to_play.each_with_index do |page, i|
                radio_button(page[:title], i, border_thickness: 0)
              end
            end

            subscribe :changed do |sender, value|
              @body_text.text = @how_to_play[value][:body].gsub('*', '&bullet;')
              current = @tab_buttons.find {|elem| elem.value == value }
              @tab_buttons.each {|t| t.enabled = (t != current) }
            end
          end

          @body_text = text_area font_size: 21, padding: 10, enabled: false,
                                 width: $window.width - 50, height: $window.height - 180

          @tabs_group.value = 0
        end

        button(shortcut("Back")) { pop_game_state }
      end
    end
  end
end
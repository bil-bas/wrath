module Wrath
  class Instructions < Gui
    HOW_TO_PLAY = File.join(File.dirname(__FILE__), 'instructions.yml')

    def initialize
      super

      on_input([:escape, :b], :pop_game_state)

      pack :vertical do
        label "Instructions", font_size: 32

        @how_to_play = YAML.load(File.read(HOW_TO_PLAY))

        @tabs_group = group do
          pack :horizontal, padding: 0, spacing: 0 do
            @how_to_play.each_with_index do |page, i|
              radio_button(page[:title], i)
            end
          end

          subscribe :changed do |sender, value|
            @body_text.text = @how_to_play[value][:body]
          end
        end

        @body_text = text_area font_size: 20, padding: 10, enabled: false,
                               width: $window.width - 50, height: $window.height - 200

        @tabs_group.value = 0

        button("(B)ack") { pop_game_state }
      end
    end
  end
end
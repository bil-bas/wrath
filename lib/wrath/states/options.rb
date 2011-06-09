module Wrath
  class Options < Gui
    PAGES = {
        OptionsAudio => :audio,
        OptionsVideo => :video,
        OptionsControls => :controls,
    }

    def initialize
      super

      vertical do
        label t.title, font_size: 32

        vertical padding: 0, spacing: 10 do
          PAGES.each_pair do |state, button|
            image = Image["gui/#{Chingu::Inflector.underscore(Inflector.demodulize(state.name))}.png"]
            button(t.button[button].text, shortcut: true, icon: ScaledImage.new(image, $window.sprite_scale), width: 300) { push_game_state state }
          end
        end

        horizontal padding: 0 do
          button(t.button.back.text, shortcut: true) { pop_game_state }

          button(t.button.default.text, tip: t.button.default.tip) do
            settings.reset_to_default
            controls.reset_to_default
          end
        end
      end
    end
  end
end
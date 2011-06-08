module Wrath
  class Options < Gui
    PAGES = {
        OptionsAudio => :audio,
        OptionsVideo => :video,
        OptionsControls => :controls,
    }

    def initialize
      super

      PAGES.each_pair do |state, button|
        on_input(t.button[button].text[0].downcase.to_sym, state)
      end

      vertical do
        label t.title, font_size: 32

        vertical padding: 0, spacing: 10 do
          PAGES.each_pair do |state, button|
            image = Image["gui/#{Chingu::Inflector.underscore(Inflector.demodulize(state.name))}.png"]
            button(shortcut(t.button[button].text), icon: ScaledImage.new(image, $window.sprite_scale), width: 300) { push_game_state state }
          end
        end

        horizontal padding: 0 do
          button(shortcut(t.button.back.text)) { pop_game_state }

          button(t.button.default.text, tip: t.button.default.tip) do
            settings.reset_to_default
            controls.reset_to_default
          end
        end
      end
    end
  end
end
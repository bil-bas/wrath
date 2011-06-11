module Wrath
  class Options < Gui
    PAGES = {
        OptionsAudio => :audio,
        OptionsVideo => :video,
        OptionsControls => :controls,
        OptionsGeneral => :general,
    }

    def setup
      super

      vertical do
        label t.title, font_size: 8

        vertical padding: 0, spacing: 2.5 do
          PAGES.each_pair do |state, button|
            image = Image["gui/#{Chingu::Inflector.underscore(Inflector.demodulize(state.name))}.png"]
            button(t.button[button].text, shortcut: :auto, icon: image, width: 75) { push_game_state state }
          end
        end

        horizontal padding: 0 do
          button(t.button.back.text, shortcut: :auto) { pop_game_state }

          button(t.button.default.text, tip: t.button.default.tip) do
            settings.reset_to_default
            controls.reset_to_default

            # Just in case we reset the language.
            R18n.from_env LANG_DIR, settings[:locale]
            $window.options_changed
          end
        end
      end
    end
  end
end
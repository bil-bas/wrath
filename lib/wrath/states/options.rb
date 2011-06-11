module Wrath
  class Options < Gui
    PAGES = {
        OptionsAudio => :audio,
        OptionsVideo => :video,
        OptionsControls => :controls,
        OptionsGeneral => :general,
    }

    def body
      PAGES.each_pair do |state, button|
        image = Image["gui/#{Chingu::Inflector.underscore(Inflector.demodulize(state.name))}.png"]
        button(t.button[button].text, shortcut: :auto, icon: image, width: 75) { push_game_state state }
      end
    end

    def extra_buttons
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
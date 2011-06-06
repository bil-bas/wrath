module Wrath
  class Options < Gui
    PAGES = {
        OptionsAudio => "(A)udio",
        OptionsVideo => "(V)ideo",
        OptionsControls => "(C)ontrols",
    }

    def initialize
      super

      add_inputs(
        a: OptionsAudio,
        c: OptionsControls,
        v: OptionsVideo,
        b: :pop_game_state,
        escape: :pop_game_state
        )

      vertical do
        label "Options", font_size: 32

        vertical padding: 0, spacing: 10 do
          PAGES.each_pair do |state, label|
            image = Image["gui/#{Chingu::Inflector.underscore(Inflector.demodulize(state.name))}.png"]
            button(label, icon: ScaledImage.new(image, $window.sprite_scale), width: 300) { push_game_state state }
          end
        end

        horizontal padding: 0 do
          button("(B)ack") { pop_game_state }

          button("Default all options", tip: "Reset all options (audio, video and controls) to their default values") do
            settings.reset_to_default
            controls.reset_to_default
          end
        end
      end
    end
  end
end
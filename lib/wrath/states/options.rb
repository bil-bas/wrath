module Wrath
  class Options < Gui
    PAGES = {
        OptionsAudio => "(A)udio",
        #OptionsVideo => "(V)ideo",
        OptionsControls => "(C)ontrols",
    }

    def initialize
      super

      add_inputs(
        a: OptionsAudio,
        c: OptionsControls,
        b: :pop_game_state,
        escape: :pop_game_state
        )

      vertical do
        label "Options", font_size: 32

        horizontal padding: 0 do
          PAGES.each_pair do |state, label|
            button(label) { push_game_state state }
          end
        end

        horizontal padding: 0 do
          button("(B)ack") { pop_game_state }
        end
      end
    end
  end
end
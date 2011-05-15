require 'rbconfig'

module Wrath
  class OptionsVideo < Gui
    trait :timer

    def initialize
      super

      on_input(:escape, :pop_game_state)


      pack :vertical, spacing: 20, padding: 20 do
        label "Options  |  Video", font_size: 24

        pack :horizontal, padding: 0 do
          toggle_button "Fullscreen?", value: settings[:video, :full_screen] do |sender, value|
            settings[:video, :full_screen] = value
            @edit_button.enabled = true
            @warning_label.text = "Changes require that the game be restarted"
          end

          label "(#{$window.send :screen_width}x#{$window.send :screen_height})"
        end

        @warning_label = label " "

        pack :horizontal, padding: 0, spacing: 20 do
          button("Back") { pop_game_state }
          @edit_button = button("Exit", enabled: false) do
            log.info { "Restarting game to change video options (\"#{RbConfig.ruby}\" \"#{$0}\")" }
            game_state_manager.pop_until_game_state Menu
            current_game_state.close
          end
        end
      end
    end
  end
end
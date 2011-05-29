module Wrath
  class OptionsVideo < Gui
    trait :timer

    def initialize
      super

      on_input(:escape, :pop_game_state)


      vertical spacing: 20, padding: 20 do
        label "Options  |  Video", font_size: 32

        horizontal padding: 0 do
          toggle_button "Fullscreen?", value: settings[:video, :full_screen] do |sender, value|
            settings[:video, :full_screen] = value
            @exit_button.enabled = true
            @warning_label.text = "Changes require that the game be restarted"
          end

          label "(#{$window.send :screen_width}x#{$window.send :screen_height})"
        end

        @warning_label = label " "

        horizontal padding: 0, spacing: 20 do
          button("Back") { pop_game_state }
          @exit_button = button("Exit", enabled: false) do
            pop_until_game_state Menu
            current_game_state.close
          end
        end
      end
    end
  end
end
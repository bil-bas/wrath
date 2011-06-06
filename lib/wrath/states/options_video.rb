module Wrath
  class OptionsVideo < Gui
    SCALE_RANGE = 4..12
    DEFAULT_SCALE = 4

    def initialize
      super

      on_input([:b, :escape], :pop_game_state)

      vertical do
        label "Options  |  Video", font_size: 32

        horizontal padding: 0 do
          label "Window size"

          @window_scale_combo = combo_box value: settings[:video, :window_scale], width: 250 do
            SCALE_RANGE.each do |scale|
              w, h = retro_width * scale, retro_height * scale
              if w <= max_window_width and h <= max_window_height
                default = (scale == DEFAULT_SCALE ? '<default>' : '')
                item "#{w}x#{h} (X#{scale} zoom) #{default}", scale
              end
            end

            subscribe :changed do |sender, scale|
              settings[:video, :window_scale] = scale
              require_restart
            end
          end
        end
=begin
        horizontal padding: 0 do
          toggle_button "Fullscreen?", value: settings[:video, :full_screen] do |sender, value|
            settings[:video, :full_screen] = value
            require_restart
          end

          label "(#{screen_width}x#{screen_height})"
        end
=end
        @warning_label = label " "

        horizontal padding: 0, spacing: 20 do
          button(shortcut("Back")) { pop_game_state }
          button("Defaults", tip: "Reset to default values") do
            @window_scale_combo.value = DEFAULT_SCALE
          end

          @exit_button = button("Exit", enabled: false) do
            pop_until_game_state Menu
            current_game_state.close
          end
        end
      end

      require_restart # Probably not necessary.
    end

    def require_restart
      if @window_scale_combo.value == sprite_scale
        @exit_button.enabled = false
        @warning_label.text = ""
      else
        @exit_button.enabled = true
        @warning_label.text = "Changes require that the game be restarted"
      end
    end
  end
end
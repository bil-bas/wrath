module Wrath
  class OptionsVideo < Gui
    include ShownOverNetworked

    SCALE_RANGE = 4..12
    DEFAULT_SCALE = 4

    def body
      horizontal padding: 0 do
        group do
          grid num_columns: 2, padding: 0 do
            # Windowed options.
            radio_button t.button.windowed.text, false, width: 80, tip: t.button.windowed.tip

            @window_scale_combo = combo_box value: settings[:video, :window_scale], width: 90, align: :center do
              SCALE_RANGE.each do |scale|
                w, h = $window.width * scale, $window.height * scale
                if w <= max_window_width and h <= max_window_height
                  item "#{w}x#{h} #{t.zoom(scale)}", scale
                end
              end

              subscribe :changed do |sender, scale|
                settings[:video, :window_scale] = scale
                require_restart
              end
            end

            # full-screen options.
            radio_button t.button.full_screen.text, true, width: 80, tip: t.button.full_screen.tip

            label "#{screen_width}x#{screen_height}"
          end

          self.value = settings[:video, :full_screen]

          subscribe :changed do |sender, value|
            settings[:video, :full_screen] = value
            @window_scale_combo.enabled = (not value)
            require_restart
          end
        end
      end

      @warning_label = label " "
    end

    def extra_buttons
      button(t.button.default.text, tip: t.button.default.tip) do
        @window_scale_combo.value = DEFAULT_SCALE
      end

      @exit_button = button(t.button.exit.text, enabled: false) do
        pop_until_game_state Menu
        current_game_state.close
      end
    end

    def require_restart
      @exit_button.enabled = true
      @warning_label.text = t.label.warning
    end
  end
end
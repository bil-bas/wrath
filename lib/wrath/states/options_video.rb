module Wrath
  class OptionsVideo < Gui
    SCALE_RANGE = 4..12
    DEFAULT_SCALE = 4

    def setup
      super

      vertical do
        label t.title, font_size: 32

        horizontal padding: 0 do
          label t.label.window_size

          @window_scale_combo = combo_box value: settings[:video, :window_scale], width: 250 do
            SCALE_RANGE.each do |scale|
              w, h = retro_width * scale, retro_height * scale
              if w <= max_window_width and h <= max_window_height
                item "#{w}x#{h} #{t.zoom(scale)}", scale
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
          button(t.button.back.text, shortcut: :auto) { pop_game_state }
          button(t.button.default.text, tip: t.button.default.tip) do
            @window_scale_combo.value = DEFAULT_SCALE
          end

          @exit_button = button(t.button.exit.text, enabled: false) do
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
        @warning_label.text = t.label.warning
      end
    end
  end
end
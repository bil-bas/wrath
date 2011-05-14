module Wrath
  class OptionsControls < Gui

    GROUPS = {
        local_player_1:
            { title: "Player 1", tip: "Controls for player 1 (left side) when sharing the keyboard" },
        local_player_2:
            { title: "Player 2", tip: "Controls for player 2 (right side) when sharing the keyboard" },
        network_player:
            { title: "Network player", tip: "Controls for the local player in a network game" },
    }

    public
    def initialize
      super

      on_input(:escape) { pop_game_state }

      @controls = Settings.new(Player::KEYS_CONFIG_FILE)

      @control_waiting_for_key = nil

      init_key_codes

      pack :vertical, spacing: 24 do
        label "Options  |  Controls"

        # Choose control group.

        @tabs_group = group do
          pack :horizontal do
            GROUPS.each_pair do |symbol, options|
              radio_button(options[:title], symbol, tip: options[:tip].to_s)
            end
          end

          subscribe :changed do |sender, value|
            @control_waiting_for_key = nil
            list_keys
          end
        end

        scroll_window height: 250, width: 600 do
          @key_grid = pack :grid, num_columns: 2, spacing: 10, padding: 10
        end

        pack :horizontal do
          button("Back") { pop_game_state }
        end
      end

      @tabs_group.value = GROUPS.keys.first
    end

    public
    def update
      if @control_waiting_for_key
        # Check every key to see if it pressed and a valid key.
        @key_codes.each do |code|
          if $window.button_down?(code)
            # If it is defined in Chingu, allow its use. If not, leave the key as it is.
            if symbols = Chingu::Input::CONSTANT_TO_SYMBOL[code]
              symbol = symbols.first
              symbol = :space if symbol == :' '
              @controls[@tabs_group.value, @control_waiting_for_key] = symbol
            end

            @control_waiting_for_key = nil
            list_keys
          end
        end
      end

      super
    end

    protected
    # Get all possible key codes supported by Gosu, except escape, which takes us out of the screen.
    def init_key_codes
      @key_codes = (Gosu::KbRangeBegin..Gosu::KbRangeEnd).to_a +
          (Gosu::GpRangeBegin..Gosu::GpRangeEnd).to_a -
          [Gosu::KbEscape]
    end

    protected
    # Make a new list of keys in the main part of the window.
    def list_keys
      @key_grid.with do
        clear

        @controls.keys(@tabs_group.value).each do |control|
          key_label = label control.to_s.capitalize.tr('_', ' ')
          key_name = @controls[@tabs_group.value, control]
          button(key_name.to_s.tr('_', ' '), width: 400) { choose_key control, key_label }
        end
      end
    end

    protected
    # Get ready to pick a key.
    def choose_key(control, key_label)
      key_label.color = Color.rgb(255, 0, 0)
      @control_waiting_for_key = control
      @key_grid.each {|element| element.enabled = false if element.is_a? Fidgit::Button }
    end
  end
end
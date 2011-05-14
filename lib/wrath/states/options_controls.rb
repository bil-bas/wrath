module Wrath
  class OptionsControls < Gui

    GROUPS = {
        singleplayer_player_1: "Player 1",
        singleplayer_player_2: "Player 2",
        multiplayer:           "Multi-player",
        #general: "General",
    }

    public
    def initialize
      super

      on_input(:escape) { pop_game_state }

      @controls = Settings.new(Player::KEYS_CONFIG_FILE)


      @waiting_for_key = nil

      init_key_codes

      pack :vertical, spacing: 24 do
        label "Options  |  Controls"

        # Choose control group.
        pack :horizontal do
          @group_buttons = []
          GROUPS.each_pair do |symbol, label|
            @group_buttons << button(label) { |sender| choose_group sender, symbol }
          end
        end

        scroll_window height: 250, width: 600 do
          @key_grid = pack :grid, num_columns: 2, spacing: 10, padding: 10
        end

        pack :horizontal do
          button("Back") { pop_game_state }
        end
      end

      choose_group @group_buttons.first, GROUPS.keys.first
    end

    public
    def update
      if @control
        # Check every key to see if it pressed and a valid key.
        @key_codes.each do |code|
          if $window.button_down?(code)
            if symbols = Chingu::Input::CONSTANT_TO_SYMBOL[code]
              symbol = symbols.first
              symbol = :space if symbol == :' '
              @controls[@group, @control] = symbol
            end

            @control = nil
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
    def choose_group(button, symbol)
      @group_buttons.each {|b| b.enabled = (b != button) }
      @group = symbol
      list_keys
    end

    protected
    def list_keys
      @key_grid.with do
        clear

        @controls.keys(@group).each do |control|
          key_label = label control.to_s.capitalize.tr('_', ' ')
          key_name = @controls[@group, control]
          button(key_name.to_s.tr('_', ' '), width: 400) { choose_key control, key_label }
        end
      end
    end

    protected
    def choose_key(control, key_label)
      key_label.color = Color.rgb(255, 0, 0)
      @control = control
    end
  end
end
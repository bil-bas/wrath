module Wrath
  class OptionsControls < Gui
    include ShownOverNetworked

    TABS = [:offline_player_1, :offline_player_2, :online_player, :general]

    def escape_disabled?; !!@control_waiting_for_key; end

    def initialize
      super

      @control_waiting_for_key = nil

      init_key_codes
    end

    def setup
      init_translations
      super
    end

    public
    def body
      vertical spacing: 0, padding: 0 do
        # Choose control group.
        @tabs_group = group do
          @tab_buttons = horizontal padding: 0, spacing: 2 do
            TABS.each do |name|
              radio_button(t.tab[name].text, name, tip: t.tab[name].tip, border_thickness: 0)
            end
          end

          subscribe :changed do |sender, value|
            @control_waiting_for_key = nil
            list_keys

            current = @tab_buttons.find {|elem| elem.value == value }
            @tab_buttons.each {|t| t.enabled = (t != current) }
            current.color, current.background_color = current.background_color, current.color
          end
        end

        scroll_window height: 80, width: $window.width - 10, background_color: BACKGROUND_COLOR do
          @key_grid = grid num_columns: 2, padding: 2.5, spacing: 2.5
        end
      end

      @tabs_group.value = TABS.first
    end

    def extra_buttons
      button(t.button.default.text, tip: t.button.default.tip) do
        message(t.dialog.confirm_default.message, type: :ok_cancel) do |result|
          if result == :ok
            controls.reset_to_default
            $window.options_changed
          end
        end
      end
    end


    public
    def update
      if @control_waiting_for_key
        # Check every key to see if it pressed and a valid key.
        @key_codes.each do |code|
          if $window.button_down?(code)
            # If it is defined in Chingu, allow its use. If not, leave the key as it is.
            if symbols = Chingu::Input::CONSTANT_TO_SYMBOL[code]
              controls[@tabs_group.value, @control_waiting_for_key] = symbols.first
            end

            @control_waiting_for_key = nil
            list_keys
          end
        end
      end

      super
    end

    protected
    # Get all possible key codes supported by Gosu.
    def init_key_codes
      @key_codes = (Gosu::KbRangeBegin..Gosu::KbRangeEnd).to_a +
          (Gosu::GpRangeBegin..Gosu::GpRangeEnd).to_a
    end

    protected
    # Try to find a translation for at least one of the key-symbols, then apply that translation to all key-symbols
    # in this group.
    def init_translations
      @key_translations = {}

      translations = R18n.get.t.controls

      Input::CONSTANT_TO_SYMBOL.values.each do |keys|
        translation = nil

        keys.each do |key|
          translation = case key.to_s
                          when /^f(\d+)/
                            translations.function($1)
                          when /^keypad_(.*)/
                            translations.keypad($1)
                          when /^numpad_(.*)/
                            translations.numpad($1)
                          when /^gamepad_button_(.*)/
                            translations.gamepad_button($1)
                          when /^gamepad_(.*)/
                            translations.gamepad($1)
                          when 'a'..'z'
                            Window.button_id_to_char(Input::SYMBOL_TO_CONSTANT[key]).capitalize
                          when '0'..'9'
                            key
                          else
                            translations[key]
                        end

          break if translation
        end

        unless translation and ((not translation.respond_to?(:translated?)) or translation.translated?)
          raise "Failed to find translation for any of #{keys.inspect}"
        end

        keys.each {|key| @key_translations[key] = translation }
      end
    end

    protected
    # Make a new list of keys in the main part of the window.
    def list_keys
      @key_grid.with do
        clear

        controls.keys(@tabs_group.value).each do |control|
          key_label = label t.label[control], width: 80
          key = controls[@tabs_group.value, control]
          button(@key_translations[key], width: 75) { choose_key control, key_label }
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
module Gosu
  class Color
    def to_hex
      "%02x%02x%02x" % [red, green, blue]
    end
  end
end

module Fidgit
  class Button
    DEFAULT_SHORTCUT_COLOR = Gosu::Color.rgb(136, 187, 255)

    alias_method :old_initialize, :initialize
    def initialize(text, options = {})
      options = {
        shortcut_color: DEFAULT_SHORTCUT_COLOR,
        shortcut: false,
      }.merge! options

      old_initialize(text, options)

      @shortcut_color = options[:shortcut_color].dup

      if options[:shortcut] and not text.empty?
        shortcut = text[0]
        state = $window.game_state_manager.inside_state || $window.current_game_state
        state.on_input(shortcut.downcase.to_sym) { activate unless state.focus }
        self.text = text.sub(/#{shortcut}/i) {|char| "<c=#{@shortcut_color.to_hex}>#{char}</c>" }
      end
    end

    def activate
      publish(:clicked_left_mouse_button, x + width / 2, y + height / 2) if enabled?
    end
  end
end
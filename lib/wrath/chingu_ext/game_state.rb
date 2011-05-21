module Chingu
  class GameState
    include Wrath::Log

    SETTINGS_CONFIG_FILE = 'settings.yml' # The general settings file.
    STATISTICS_CONFIG_FILE = 'statistics.yml'

    MAX_FRAME_TIME = 100 # Milliseconds cap on frame calculations.

    # Settings object, containing general settings from config.
    def self.settings; @@settings ||= Wrath::Settings.new(SETTINGS_CONFIG_FILE); end
    def settings; self.class.settings; end

    def self.statistics; @@statistics ||= Wrath::Settings.new(STATISTICS_CONFIG_FILE, auto_save: false); end
    def statistics; self.class.statistics; end

    alias_method :original_initialize, :initialize
    public
    def initialize(options = {})
      on_input(:f12) { pry } if respond_to? :pry
      original_initialize(options)
    end

    public
    # Milliseconds since the last frame, but capped, so we don't break physics.
    def frame_time
      [$window.dt, MAX_FRAME_TIME].min
    end

    public
    # Find an object, via its network ID.
    def object_by_id(id)
      game_objects.object_by_id(id)
    end

    public
    # Do we allow a specific network message to perform its action?
    def accept_message?(message); false; end
  end
end
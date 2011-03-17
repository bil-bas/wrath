module Chingu
  class GameState
    include Wrath::Log

    SETTINGS_CONFIG_FILE = 'settings.yml' # The general settings file.

    MAX_FRAME_TIME = 100 # Milliseconds cap on frame calculations.

    alias_method :original_initialize, :initialize

    public
    def initialize(options = {})
      @@settings ||= Wrath::Settings.new(SETTINGS_CONFIG_FILE)
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

    protected
    # Read from the general settings file.
    def setting(*keys)
      @@settings[*keys]
    end

    protected
    # Write access to the general settings file.
    def set_setting(*keys, value)
      @@settings[*keys] = value
    end
  end
end
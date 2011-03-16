module Chingu
  class GameState
    include Wrath::Log

    SETTINGS_CONFIG_FILE = File.join(ROOT_PATH, 'config', 'settings.yml')
    DEFAULT_SETTINGS_CONFIG_FILE = File.join(EXTRACT_PATH, 'lib', 'wrath', 'default_config', 'settings.yml')

    MAX_FRAME_TIME = 100 # Milliseconds cap on frame calculations.

    def setup
      on_input(:f12) { pry } if respond_to? :pry
    end

    # Milliseconds since the last frame, but capped, so we don't break physics.
    def frame_time
      [$window.dt, MAX_FRAME_TIME].min
    end

    def object_by_id(id)
      game_objects.object_by_id(id)
    end

    # Do we allow a specific network message to perform its action?
    def accept_message?(message); false; end

    def load_settings
      user_settings = YAML::load(File.read(SETTINGS_CONFIG_FILE))
      default_settings = YAML::load(File.read(DEFAULT_SETTINGS_CONFIG_FILE))
      @@settings = default_settings.merge user_settings
      save_settings
      log.debug { "Loaded settings: #{@@settings.inspect}" }
    end

    def setting(key)
      load_settings unless defined? @@settings
      raise "Tried to read non-existent key, #{key}, in settings file" unless @@settings.has_key? key

      @@settings[key]
    end

    def set_setting(key, value)
      load_settings unless defined? @@settings
      raise "Tried to set non-existent key, #{key}, in settings file" unless @@settings.has_key? key

      @@settings[key] = value
      save_settings
    end

    def save_settings
      if @@settings
        File.open(SETTINGS_CONFIG_FILE, "w") {|f| f.puts @@settings.to_yaml }
      end
    end
  end
end
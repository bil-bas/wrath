module Wrath
  class Settings
    include Log

    USER_CONFIG_DIR = File.expand_path(File.join('~', '.wrath_spooner', 'config'))
    DEFAULT_CONFIG_DIR = File.join(EXTRACT_PATH, 'lib', 'wrath', 'default_config')

    public
    def initialize(settings_file)
      @default_file = File.join(DEFAULT_CONFIG_DIR, settings_file)
      @user_file = File.join(USER_CONFIG_DIR, settings_file)

      FileUtils.mkdir_p USER_CONFIG_DIR

      unless File.exists? @user_file
        log.debug { "User lacks settings file '#{@user_file}', so copying the default one" }
        FileUtils.cp @default_file, @user_file
      end

      load_settings
    end

    public
    # Read a settings value.
    #
    # @example
    #    left = settings[:keys, :player1, :left]
    def [](*keys)
      value = @settings

      keys.each_with_index do |key, i|
        unless value.is_a? Hash and value.has_key? key
          raise "Tried to read non-existent key, '#{keys[0..i].join('/')}', in settings file"
        end

        value = value[key]
      end

      raise "Tried to directly access group, '#{keys.join('/')}', rather than a key, in settings file" if value.is_a? Hash

      value
    end

    public
    # Get a list of keys for a given group.
    def keys(*keys)
      value = @settings

      keys.each_with_index do |key, i|
        unless value.is_a? Hash and value.has_key? key
          raise "Tried to read non-existent key, '#{keys[0..i].join('/')}', in settings file"
        end

        value = value[key]
      end

      raise "Tried to get keys from data entry, '#{keys.join('/')}', rather than a key group, in settings file" unless value.is_a? Hash

      value.keys
    end

    public
    # Write a settings value.
    #
    # @example
    #    settings[:keys, :player1, :left] = :a
    def []=(*keys, value)
      hash = @settings

      keys[0...-1].each_with_index do |key, i|
        unless hash.is_a? Hash and hash.has_key? key
          raise "Tried to set non-existent key, '#{keys[0..i].join('/')}', in settings file"
        end

        hash = hash[key]
      end

      if hash[keys.last].is_a? Hash
        raise "Tried to overwrite group, '#{keys.join('/')}', in settings file"
      end

      hash[keys.last] = value

      save_settings

      value
    end

    protected
    # Loads settings from the user file, using default settings if they are missing.
    def load_settings
      user_settings = YAML::load(File.read(@user_file))
      default_settings = YAML::load(File.read(@default_file))

      @settings = default_settings.deep_merge user_settings
      save_settings

      log.debug { "Loaded settings from '#{@user_file}': #{@settings.inspect}" }
    end

    protected
    # Saves the settings to the user's version of the file.
    def save_settings
      File.open(@user_file, "w") {|f| f.puts @settings.to_yaml }
    end
  end
end
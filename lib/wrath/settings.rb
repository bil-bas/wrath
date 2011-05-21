module Wrath
  class Settings
    include Log

    USER_CONFIG_DIR = File.expand_path(File.join('~', '.wrath_spooner', 'config'))
    DEFAULT_CONFIG_DIR = File.join(EXTRACT_PATH, 'lib', 'wrath', 'default_config')

    attr_writer :auto_save
    def auto_save?; @auto_save; end

    public
    def initialize(settings_file, options = {})
      options = {
          auto_save: true,
      }.merge! options

      @auto_save = options[:auto_save]
      @default_file = File.join(DEFAULT_CONFIG_DIR, settings_file)
      @user_file = File.join(USER_CONFIG_DIR, settings_file)

      FileUtils.mkdir_p USER_CONFIG_DIR

      unless File.exists? @user_file
        log.debug { "User lacks settings file '#{@user_file}', so copying the default one" }
        FileUtils.cp @default_file, @user_file
      end

      load
    end

    public
    # Read a settings value.
    #
    # @example
    #    left = settings[:keys, :player1, :left]
    def [](*keys)
      group = find_group(*keys[0...-1])

      value = group[keys.last]

      if value.is_a? Hash
        raise "Tried to directly access group, '#{keys.join('/')}', rather than a key, in settings file"
      end

      value
    end

    public
    # Get a list of keys for a given group.
    def keys(*keys)
      group = find_group(*keys)

      unless group.is_a? Hash
        raise "Tried to get keys from data entry, '#{keys.join('/')}', rather than a key group, in settings file"
      end

      group.keys
    end

    public
    # Increase the value of a given key (+1). Set to 1 if key unset.
    def increment(*keys)
      self[*keys] = (self[*keys] || 0) + 1
    end

    public
    # Write a settings value.
    #
    # @example
    #    settings[:keys, :player1, :left] = :a
    def []=(*keys, value)
      group = find_group(*keys[0...-1])

      if group[keys.last].is_a? Hash
        raise "Tried to overwrite group, '#{keys.join('/')}', in settings file"
      end

      group[keys.last] = value

      save if auto_save?

      value
    end

    protected
    # Gets a group (hash) from the settings file, creating any hashes as necessary.
    def find_group(*keys)
      group = @settings

      keys.each do |key|
        group[key] = {} unless group.has_key? key
        group = group[key]
        raise "Trying to find a group that isn't a hash, '#{keys.join('/')}'" unless group.is_a? Hash
      end

      group
    end

    protected
    # Loads settings from the user file, using default settings if they are missing.
    def load
      user_settings = YAML::load(File.read(@user_file))
      default_settings = YAML::load(File.read(@default_file))

      @settings = default_settings.deep_merge user_settings
      save if auto_save?

      log.debug { "Loaded settings from '#{@user_file}': #{@settings.inspect}" }
    end

    public
    # Saves the settings to the user's version of the file.
    def save
      File.open(@user_file, "w") {|f| f.puts @settings.to_yaml }
    end
  end
end
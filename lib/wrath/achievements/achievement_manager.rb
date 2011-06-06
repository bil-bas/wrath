module Wrath
  class AchievementManager
    include Fidgit::Event

    DEFINITIONS_FILE = File.join(File.dirname(__FILE__), 'achievement_definitions.yml')

    event :on_achievement_gained # [sender, achievement]
    event :on_unlock_gained # [sender, unlock]

    attr_reader :statistics, :achievements

    def unlocks_disabled?; @unlocks_disabled; end
    def unlocks_disabled=(value); @unlocks_disabled = value; end

    public
    def initialize(achievements_settings_file, statistics)
      @achievements_settings = Settings.new(achievements_settings_file, auto_save: false)
      @statistics = statistics

      # Every time statistics are updated, force all achievements to be re-calculated.
      @statistics.subscribe(:on_changed) do |sender, keys, value|
        @monitors[keys].each {|achievement| achievement.monitor_updated }
      end

      @unlocks_disabled = false # Used in debugging to unlock all temporarily.

      load
    end

    protected
    def load
      @achievements = []
      @unlocks = {}

      @monitors = Hash.new {|hash, key| hash[key] = [] }

      definitions = YAML.load(File.read(DEFINITIONS_FILE))
      definitions.each do |definition|
        already_done = @achievements_settings[definition[:name], :achieved] || false
        @achievements << Achievement.new(definition, self, already_done)
      end
    end

    public
    # Clear ALL statistics and achievements!
    def reset
      @statistics.reset_to_default
      @statistics.save
      save
      load
    end

    public
    def add_monitor(achievement, keys)
      @monitors[keys] << achievement

      nil
    end

    public
    def remove_monitor(achievement, keys)
      @monitors[keys].delete achievement

      nil
    end

    public
    def add_unlock(unlock)
      search = [unlock.type, unlock.name]
      raise "repeat unlock, #{unlock}" if @unlocks.has_key? search
      @unlocks[search] = unlock
    end

    def unlocked?(type, name)
      unlock = @unlocks[[type, name]]
      raise "undefined unlock, #{type.inspect} / #{name.inspect}" unless unlock

      unlock.unlocked? or @unlocks_disabled
    end

    def completion_time(name)
      time = @achievements_settings[name, :time]
      raise "No such achievement, #{name.inspect}" unless time
      time
    end

    public
    def achieve(achievement)
      @achievements_settings[achievement.name, :complete] = true
      @achievements_settings[achievement.name, :time] = Time.now.localtime

      publish :on_achievement_gained, achievement
      achievement.unlocks.each {|unlock| publish :on_unlock_gained, unlock }

      nil
    end

    public
    def save
      @achievements_settings.save
    end
  end
end
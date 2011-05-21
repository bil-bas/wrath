module Wrath
  class AchievementManager
    include Fidgit::Event

    DEFINITIONS_FILE = File.join(File.dirname(__FILE__), 'achievement_definitions.yml')

    event :on_achievement_gained # [sender, achievement]
    event :on_unlock_gained # [sender, unlock]

    attr_reader :statistics, :unlocks

    public
    def initialize(achievements_settings_file, statistics)
      @achievements_settings = Settings.new(achievements_settings_file, auto_save: false)
      @statistics = statistics

      @achievements = []
      @unlocks = []

      @monitors = Hash.new {|hash, key| hash[key] = [] }

      # Every time statistics are updated, force all achievements to be re-calculated.
      @statistics.subscribe(:on_changed) do |sender, keys, value|
        @monitors[keys].each {|achievement| achievement.monitor_updated }
      end

      definitions = YAML.load(File.read(DEFINITIONS_FILE))
      definitions.each do |definition|
        already_done = @achievements_settings[definition[:name], :achieved] || false
        @achievements << Achievement.new(definition, self, already_done)
      end
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
    def achieve(achievement)
      @achievements_settings[achievement.name, :complete] = true
      @achievements_settings[achievement.name, :date] = Time.now

      @unlocks += achievement.unlocks

      publish :on_achievement_gained, achievement

      nil
    end

    public
    def save
      @achievements_settings.save
    end
  end
end
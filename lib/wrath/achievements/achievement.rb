module Wrath
  class Achievement
    include Fidgit::Event
    include Log

    event :on_achieved

    attr_reader :name, :unlocks

    def achieved?; @achieved; end

    public
    def initialize(definition, manager, already_done)
      @achieved = already_done
      @manager = manager

      @name = definition[:name]
      @description = definition[:description]
      @statistics = definition[:statistics]
      @required = definition[:required]
      @unlocks = definition[:unlocks].map {|definition| Unlock.new(definition) }

      check_statistics

      unless achieved?
        @statistics.each do |statistic|
          @manager.add_monitor(self, statistic)
        end
      end
    end

    public
    def monitor_updated
      check_statistics

      nil
    end

    protected
    def check_statistics
      return if achieved?

      total = 0
      @statistics.each do |statistic_keys|
        total += @manager.statistics[*statistic_keys] || 0
      end

      if total >= @required
        @achieved = true
        @statistics.each do |statistic|
          @manager.remove_monitor(self, statistic)
        end
        log.info { "Achieved: #{name}" }
        @manager.achieve(self)
        publish :on_achieved
      end

      nil
    end
  end
end
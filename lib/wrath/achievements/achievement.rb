module Wrath
  class Achievement
    include Fidgit::Event
    include Log

    event :on_achieved

    attr_reader :name, :description, :title, :unlocks, :total, :progress, :required

    def complete?; @complete; end

    public
    def initialize(definition, manager, already_done)
      @complete = already_done
      @manager = manager

      @name = definition[:name]
      @title = definition[:title]
      @description = definition[:description]
      @statistics = definition[:statistics]
      @required = definition[:required]
      @unlocks = definition[:unlocks].map {|definition| Unlock.new(definition) }

      calculate_progress

      unless complete?
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
    def calculate_progress
      @total = 0
      @statistics.each do |statistic_keys|
        @total += @manager.statistics[*statistic_keys] || 0
      end

      # If already complete, it stays that way.
      @complete ||= (@total >= @required)
      @progress = @complete ? 1.0 : (@total.to_f / @required)

      nil
    end

    protected
    def check_statistics
      return if complete?
      calculate_progress
      if complete?
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
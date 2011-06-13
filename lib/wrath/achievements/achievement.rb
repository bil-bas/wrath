module Wrath
  class Achievement
    include Fidgit::Event
    include Log

    event :on_achieved

    attr_reader :name, :unlocks, :total, :progress, :required

    def complete?; @complete; end

    def t; R18n.get.t.achievement; end
    def title; t[name].title; end
    def description
      if name.to_s =~ /played_(\w+)/
        t[name].description(R18n.get.t.level[$1].name)
      else
        t[name].description
      end
    end

    public
    def initialize(definition, manager, already_done)
      @complete = already_done
      @manager = manager

      @name = definition[:name]
      @statistics = definition[:statistics]
      @required = definition[:required]

      @unlocks = definition[:unlocks].map do |unlock_def|
        Unlock.new(unlock_def[:type], unlock_def[:name], @manager, unlocked: @complete, title: unlock_def[:title])
      end

      check_statistics

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
    
    def completion_time
      @manager.completion_time(self.name)
    end
    
    def icon
      @icon ||= Image["achievements/#{name}.png"]
      @locked_icon||= Image["achievements/locked/#{name}.png"]
      complete? ? @icon : @locked_icon
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

        @unlocks.each(&:unlock)

        @manager.achieve(self)
        publish :on_achieved

        log.info { "Achieved: #{name.inspect}" }
      end

      nil
    end
  end
end
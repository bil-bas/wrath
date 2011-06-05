module Wrath
  # Image is the icon to show under the player's GUI box.
  class Status < GameObject
    include Log
    include Fidgit::Event

    trait :timer

    event :on_applied # [self, creature]
    event :on_removed # [self, creature]

    attr_reader :owner # Object this status is applied to.

    def self.type; name.downcase[/[^:]+$/].to_sym; end
    def type; @type ||= self.class.type; end

    # If :duration option is missing, duration is indefinite.
    def initialize(owner, options = {})
      options = {
          image: Image["statuses/#{type}.png"]
      }.merge! options

      raise ArgumentError("Owner must be networked") unless owner.networked?

      @owner = owner

      super options

      duration_timer(options[:duration]) if options[:duration]
      
      # Ensure that the stat exists.
      parent.statistics[:status, type] = parent.statistics[:status, type] || 0.0

      publish :on_applied, @owner

      log.debug do
        duration = options[:duration] ? "for #{@duration}ms" : "indefinitely"
        "Applied status #{type} to #{@owner} #{duration}"
      end
    end
    
    def duration_timer(duration)
      after(duration, name: :duration) { remove } unless parent.client?
    end
    
    # Called if the status effect is already on an object.
    # Duration reset to that of the new duration.
    def reapply(options = {})
      if timer_exists? :duration
        stop_timer :duration
        duration_timer(options[:duration])
      end    
    end

    def update
      return unless @owner
          
      if @owner.local? and @owner.controlled_by_player?
        parent.statistics[:status, type] = parent.statistics[:status, type] + (parent.frame_time / 1000.0)
      end
      
      super
    end

    def draw
      # Disable the default draw.
    end

    # Status effect has been removed.
    def remove
      return unless @owner

      old_owner = @owner
      @owner = nil
      old_owner.remove_status(type)
      log.debug { "Removed status #{type} from #{old_owner}" }
      publish :on_removed, old_owner
    end
  end
end
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
      @duration = options[:duration]

      super options

      after(@duration) { remove } if @duration and not parent.client?

      publish :on_applied, @owner

      log.debug do
        duration = @duration ? "for #{@duration}ms" : "indefinitely"
        "Applied status #{type} to #{@owner.class}##{@owner.id} #{duration}"
      end
    end

    def update
      update_trait
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
      log.debug { "Removed status #{type} from #{old_owner.class}##{old_owner.id}" }
      publish :on_removed, old_owner
    end
  end
end
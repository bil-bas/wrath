module Wrath
  class Potion < Carriable
    def can_be_activated?(actor); false; end

    def initialize(options = {})
      options = {
        favor: 1,
        encumbrance: 0,
        elasticity: 0.4,
        factor: 0.7,
        z_offset: 0,
        duration: 5,
        factor: 0.7,
      }.merge! options

      @duration = options[:duration]

      super options
    end

    # Potion effect inflicted.
    def affect(target)
      log.debug { "Affecting #{target.class}##{target.id} with #{self.class}" }
      unaffect(target) if target.timer_exists? self.class.name.to_sym
      target.during(@duration, name: self.class.name.to_sym) { affected_update(target) }.then { unaffect(target) }
    end

    # Called each update during the duration of the potion.
    def affected_update(target)
      # Override.
    end

    # Potion effect wears off.
    def unaffect(creature)
      log.debug { "Unaffecting #{target.class}##{target.id} with #{self.class}" }
    end

    def on_collision(other)
      case other
        when Creature
            affect(other)
            destroy
      end

      super(other)
    end
  end
end
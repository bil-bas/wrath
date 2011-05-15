module Wrath
  class Ent < Humanoid
    DAMAGE = 15 / 1000.0 # damage/second

    def can_be_picked_up?(container); false; end

    def initialize(options = {})
      options = {
        favor: 0,
        health: 1000000,
        walk_interval: 100,
        elasticity: 0,
        encumbrance: Float::INFINITY,
        animation: "ent_16x16.png",
      }.merge! options

      super options
    end

    def go_to_sleep
      Tree.create(position: position, can_wake: true)
      self.destroy
    end

    def on_collision(other)
      case other
        when Ent
          # Do nothing.

        when Creature
          other.health -= DAMAGE * frame_time
      end

      super(other)
    end
  end
end
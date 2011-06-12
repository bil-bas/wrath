module Wrath
  class Ent < Humanoid
    DAMAGE = 30

    def hurts?(other); other.controlled_by_player?; end
    def can_be_picked_up?(container); false; end

    def initialize(options = {})
      options = {
          damage_per_hit: DAMAGE,
          health: 1000000,
          move_interval: 100,
          elasticity: 0,
          encumbrance: Float::INFINITY,
          animation: "ent_16x16.png",
      }.merge! options

      super options
    end

    def go_to_sleep
      Tree.create(parent: parent, position: position, can_wake: true)
      self.destroy
    end

    def knocked_down_by(other)
      # DON'T KNOCK ME DOWN!
    end
  end
end
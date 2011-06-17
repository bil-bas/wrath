module Wrath
  class Snake < Animal
    DAMAGE = 10
    POISON_DURATION = 3000

    def hurts?(other); other.controlled_by_player?; end

    def initialize(options = {})
      options = {
          favor: 8,
          factor: 0.75,
          health: 15,
          damage_per_hit: DAMAGE,
          animation: "snake_10x7.png",
          speed: 2,
          walk_duration: 500,
          move_type: :walk,
          move_interval: 1000,
          elasticity: 0,
          z_offset: -2,
      }.merge! options

      super options
    end

    def on_collision(other)
      if other.is_a? Creature and self.hurts?(other) and can_hit?(other)
        other.apply_status(:poisoned, duration: POISON_DURATION)
      end

      super(other)
    end
  end
end
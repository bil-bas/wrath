module Wrath
  class Fire < DynamicObject
    trait :timer

    BURN_DURATION = 5000
    ANIMATION_DELAY = 500
    GLOW_COLOR = Color.rgb(255, 255, 50)
    FLAME_COLOR = Color.rgba(255, 255, 255, 100)

    def initialize(options = {})
      options = {
          favor: 2,
          encumbrance: 0,
          elasticity: 0.2,
          z_offset: -2,
          animation: "fire_8x8.png",
          casts_shadow: false,
          sacrifice_particle: Spark,
          color: FLAME_COLOR,
          mode: :additive,
      }.merge! options

      super options

      @frames.delay = ANIMATION_DELAY
    end

    def update
      super

      self.image = @frames.next

      if rand(100) < 3
        Smoke.create(parent: parent, x: x - 3 + rand(4) + rand(4), y: y - z - 3 - rand(3), zorder: y - 0.01 + rand(0.02))
      end
    end

    def draw
      super

      intensity = [1.5 - (z * 0.05), 0].max
      GLOW_COLOR.alpha = (40 * intensity).to_i
      parent.draw_glow(x, y, GLOW_COLOR, intensity)
    end

    def on_collision(other)
      if other.is_a? Creature
        other.apply_status(:burning, duration: BURN_DURATION)
      end

      super(other)
    end
  end
end
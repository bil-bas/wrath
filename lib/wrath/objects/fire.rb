module Wrath
  # Fire on the ground. Can't be picked up, since it is considered to be burning what is underneath.
  class Fire < DynamicObject
    ANIMATION_INTERVAL = 500

    def can_be_picked_up?(actor); false; end
    def burning?; true; end

    def initialize(options = {})
      options = {
          animation: "fire_8x8.png",
          casts_shadow: false,
          sacrifice_particle: Spark,
          collision_height: 8,
          color: Status::Burning::FLAME_COLOR,
      }.merge! options

      super options

      @frames.delay = ANIMATION_INTERVAL
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
      parent.draw_glow(x, y, Status::Burning::GLOW_COLOR, intensity)
    end
  end
end
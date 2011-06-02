module Wrath
  class Seaweed < DynamicObject
    ANIMATION_DELAY = 1000

    def can_be_picked_up?(other); false; end

    def can_spawn_onto?(tile); tile.is_a? Sand; end

    def initialize(options = {})
      options = {
          animation: "seaweed_8x18.png",
          factor_y: random(1, 1.5),
      }.merge! options

      super options
    end

    # Animated by the level.
    def animate
      self.image = @frames.next
    end
  end
end
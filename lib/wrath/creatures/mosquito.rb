module Wrath
  class Mosquito < Animal
    DAMAGE = 0.5  / 1000.0 # 0.5/second

    def can_be_activated?(actor); false; end
    def ground_level; super + ((@state == :thrown) ? 0 : 3); end

    def initialize(options = {})
      options = {
        health: 50, # Difficult to kill, but not really too relevant.
        vertical_jump: 0.1,
        horizontal_jump: 0.1,
        elasticity: 0.9,
        jump_delay: 0,
        animation: "mosquito_8x8.png",
      }.merge! options

      super(options)
    end

    def die!; destroy; end

    def on_collision(other)
      case other
        when Mosquito
          # Do nothing.

        when Creature
          other.health -= DAMAGE * frame_time
      end

      false
    end
  end
end
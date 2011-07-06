module Wrath
  class GasJet < DynamicObject

    ANIMATION_DELAY = 250
    POISON_DURATION = 4000
    GAS_COLOR = Color.rgba(0, 200, 0, 100)

    def damage_per_second; 10; end
    def can_be_picked_up?(actor); false; end

    def initialize(options = {})
      options = {
        animation: "gas_jet_10x10.png",
        casts_shadow: false,
      }.merge! options

      super options

      @frames.delay = ANIMATION_DELAY
    end

    def update
      super

      self.image = @frames.next

      if rand(100) < 3
        Smoke.create(parent: parent, x: x - 3 + rand(4) + rand(4), y: y - z - 8 - rand(3),
                     zorder: y - 0.01 + rand(0.02), color: GAS_COLOR)
      end
    end

    def on_collision(other)
      case other
        when Creature
          other.apply_status(:poisoned, duration: POISON_DURATION) unless other.poisoned?
      end

      super(other)
    end
  end
end
module Wrath
  class StrengthPotion < Potion
    DURATION = 5000
    GROWTH_FACTOR = 1.2

    def initialize(options = {})
      options = {
        duration: DURATION,
        animation: "strength_potion_6x6.png",
      }.merge! options

      super options
    end

    def affect(creature)
      super(creature)
      creature.factor_x *= GROWTH_FACTOR
      creature.factor_y *= GROWTH_FACTOR
    end

    def unaffect(creature)
      creature.factor_x /= GROWTH_FACTOR
      creature.factor_y /= GROWTH_FACTOR
    end
  end
end
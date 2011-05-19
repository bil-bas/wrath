module Wrath
  class Status < GameObject
    # Being larger also affects your encumbrance and strength.
    class Enlarged < Status
      GROWTH_FACTOR = 1.2
      STRENGTH_BONUS = 0.2

      def on_applied(sender, creature)
        creature.strength += STRENGTH_BONUS

        creature.encumbrance *= GROWTH_FACTOR
        creature.factor_x *= GROWTH_FACTOR
        creature.factor_y *= GROWTH_FACTOR
      end

      def on_removed(sender, creature)
        creature.strength -= STRENGTH_BONUS

        creature.encumbrance /= GROWTH_FACTOR
        creature.factor_x /= GROWTH_FACTOR
        creature.factor_y /= GROWTH_FACTOR
      end
    end
  end
end
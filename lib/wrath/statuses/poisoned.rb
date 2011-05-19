module Wrath
  class Status < GameObject
    # Being poisoned makes you weaker and also
    class Poisoned < Status
      STRENGTH_PENALTY = 0.2
      OVERLAY_COLOR = Color.rgba(0, 200, 0, 150)

      # Effect needs to be applied after input, but before actual movement, so can't just be in #update.
      def displacement_angle
        Math::sin(milliseconds / 150) * 45
      end

      def draw
        @owner.image.silhouette.draw_rot(@owner.x, @owner.y - @owner.z, @owner.y,
                                         0, @owner.center_x, @owner.center_y,
                                         @owner.factor_x, @owner.factor_y,
                                         OVERLAY_COLOR)
      end

      def on_applied(sender, creature)
        creature.strength -= STRENGTH_PENALTY
      end

      def on_removed(sender, creature)
        creature.strength += STRENGTH_PENALTY
      end
    end
  end
end
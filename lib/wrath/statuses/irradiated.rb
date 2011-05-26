module Wrath
  class Status < GameObject
    STRENGTH_BONUS = 0.5
    # Being irradiated makes you strong and glowey.
    class Irradiated < Status
      OVERLAY_COLOR = Color.rgba(0, 250, 0, 100)
      DAMAGE = 5 / 1000.0

      def update
        OVERLAY_COLOR.alpha = ((2 + Math::sin(milliseconds / 500.0)) * 50).to_i
        owner.health -= DAMAGE * parent.frame_time
        super
      end
      
      def draw       
        @owner.image.outline.draw_rot(@owner.x, @owner.y + 1 - @owner.z, @owner.y,
                                         0, @owner.center_x, @owner.center_y,
                                         @owner.factor_x, @owner.factor_y,
                                         OVERLAY_COLOR, :additive)
      end

      def on_applied(sender, creature)
        creature.strength += STRENGTH_BONUS
      end

      def on_removed(sender, creature)
        creature.strength -= STRENGTH_BONUS
      end
    end
  end
end
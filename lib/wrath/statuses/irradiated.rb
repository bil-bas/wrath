require_relative "status"

module Wrath
  class Status
    # Being irradiated makes you strong and glowey.
    class Irradiated < Status
      STRENGTH_BONUS = 0.5
      OVERLAY_COLOR = Color.rgba(0, 250, 0, 100)
      DAMAGE = 3 / 1000.0

      def update
        OVERLAY_COLOR.alpha = ((1.3 + Math::sin(milliseconds / 250.0)) * 90).to_i
        owner.wound(DAMAGE * parent.frame_time, self, :over_time) unless parent.client?
        super
      end
      
      def draw
        $window.clip_to(0, 0, 10000, @owner.y) do         
          @owner.image.outline.draw_rot(@owner.x, @owner.y + 1 - @owner.z, @owner.y,
                                         0, @owner.center_x, @owner.center_y,
                                         @owner.factor_x, @owner.factor_y,
                                         OVERLAY_COLOR, :additive)
        end
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
require_relative "status"

module Wrath
  class Status
    # What you get for a moment when you stand up and at the start of a game.
    class Invulnerable < Status
      OVERLAY_COLOR = Color.rgba(0, 0, 255, 150)
      
      def draw
        $window.clip_to(0, 0, 10000, @owner.y) do
          @owner.image.outline.draw_rot(@owner.x, @owner.y + 1 - @owner.z, @owner.y,
                                         0, @owner.center_x, @owner.center_y,
                                         @owner.factor_x, @owner.factor_y,
                                         OVERLAY_COLOR, :additive)
        end
      end
    end
  end
end
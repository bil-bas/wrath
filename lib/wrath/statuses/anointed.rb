require_relative "status"

module Wrath
  class Status
    # Being anointed at the font empowers a sacrifice.
    class Anointed < Status
      GLOW_COLOR = Color.rgba(150, 150, 255, 100)
      
      def draw
        $window.clip_to(0, 0, 10000, @owner.y) do         
          @owner.image.outline.draw_rot(@owner.x, @owner.y + 1 - @owner.z, @owner.y,
                                         0, @owner.center_x, @owner.center_y,
                                         @owner.factor_x, @owner.factor_y,
                                         GLOW_COLOR, :additive)
        end
      end
    end
  end
end
module Wrath
  class ScaledImage
    def width; @image.width * @scale; end
    def height; @image.height * @scale; end

    def initialize(image, scale)
     @image, @scale = image, scale
    end

    def draw(x, y, zorder, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default)
      @image.draw x, y, zorder, factor_x * @scale, factor_y * @scale, color, mode
    end
  end
end
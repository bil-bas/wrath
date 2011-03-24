module Wrath
  class SpriteSheet
    def initialize(file, width, height, tiles_wide = 0)
      @sprites = Image.load_tiles($window, File.join(Image.autoload_dirs[0], file), width, height, false)
      @tiles_wide = tiles_wide
    end

    def [](x, y = 0)
      @sprites[y * @tiles_wide + x]
    end
  end
end
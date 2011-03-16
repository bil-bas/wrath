module Wrath
  class Map < GameObject
    trait :timer

    include Log

    def initialize(tile_classes)
      super()

      @tiles = [] # Grid of all tiles.
      @animated_tiles = [] # Tiles that require animating and drawing every frame.

      tile_classes.each_with_index do |class_row, y|
        tile_row = []
        @tiles << tile_row
        class_row.each_with_index do |type, x|
          tile = type.new(grid: [x, y])

          @animated_tiles << tile if tile.is_a? AnimatedTile

          tile_row << tile
        end
      end

      # Cache all the images into a big image, to save drawing them separately.
      @background_image = TexPlay.create_image($window, $window.retro_width, $window.retro_height)
      $window.render_to_image(@background_image) do
        @tiles.flatten.each(&:draw)
      end

      every(AnimatedTile::ANIMATION_PERIOD, &method(:update_animations).to_proc)

      log.info { "Created map of #{@tiles[0].size}x#{@tiles.size} tiles" }
    end

    # Tile at grid coordinates.
    def [](x, y)
      @tiles[y][x]
    end

    # Tile at screen coordinates.
    def tile_at_coordinate(x, y)
      @tiles[y / Tile::HEIGHT][x / Tile::WIDTH]
    end

    def draw
      @background_image.draw(0, 0, ZOrder::TILES)
      @animated_tiles.each(&:draw)
    end

    def update_animations
      @animated_tiles.each(&:animate)
    end

    def set_color(x, y, color)
      @background_image.pixel(x.round, y.round, color: color)
    end
  end
end
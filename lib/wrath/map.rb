module Wrath
  class Map < GameObject
    include Log

    def initialize(tile_classes)
      @tiles = []
      tile_classes.each_with_index do |class_row, y|
        tile_row = []
        @tiles << tile_row
        class_row.each_with_index do |type, x|
          tile_row << type.create(grid: [x, y])
        end
      end
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
  end
end
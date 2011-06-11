module Wrath
  class Map < GameObject
    trait :timer

    include Log

    attr_reader :tiles
    attr_reader :number_of_tiles_to_create

    def tiles_to_create?; @number_of_tiles_to_create > 0; end # Any more tiles to create?
    def incomplete?; not @tile_classes.nil?; end # Does the map need generating?

    def initialize(tile_classes)
      super()

      @tile_classes = tile_classes
      @x, @y = 0, -1
      @number_of_tiles_to_create = @tile_classes.size * @tile_classes.first.size
      @tiles = Array.new(@tile_classes.size) { Array.new(@tile_classes.first.size) } # Grid of all tiles.
      @animated_tiles = [] # Tiles that require animating and drawing every frame.
    end

    def generate_background
      @tile_classes = nil

      all_tiles = @tiles.flatten
      all_tiles.each(&:render_edges)

      # Cache all the images into a big image, to save drawing them separately.
      @background_image = TexPlay.create_image($window, $window.width, $window.height)
      $window.render_to_image(@background_image) do
        all_tiles.each(&:draw)
      end
      @background_image.refresh_cache

      every(AnimatedTile::ANIMATION_PERIOD, &method(:update_animations).to_proc)

      update_animations

      log.info { "Created map of #{@tiles.first.size}x#{@tiles.size} tiles" }
    end

    def create_tiles(number)
      number.times do
        return unless @number_of_tiles_to_create >= 1

        @number_of_tiles_to_create -= 1

        @y += 1
        if @y == @tiles.size
          @y = 0
          @x += 1
        end

        tile = @tile_classes[@y][@x].new(self, @x, @y)

        @animated_tiles << tile if tile.is_a? AnimatedTile

        @tiles[@y][@x] = tile
      end
    end

    # Tile at grid coordinates.
    def [](x, y)
      @tiles[y][x]
    end

    # Tile at screen coordinates.
    def tile_at_coordinate(x, y)
      @tiles[y / Tile::HEIGHT][x / Tile::WIDTH] rescue nil
    end

    def draw
      @background_image.draw(0, 0, ZOrder::TILES)
      @animated_tiles.each(&:draw)
    end

    def update_animations
      @animated_tiles.each(&:animate)
    end

    public
    # Splice an image onto the background.
    def splice(image, x, y)
      image.refresh_cache
      @background_image.splice image, x.round, y.round
    end

    public
    # Set an individual pixel color on the background.
    def set_color(x, y, color)
      @background_image.pixel(x.round, y.round, color: color)
    end

    public
    # x and y screen position, not tile position.
    def replace_tile(x, y, type)
      old_tile = tile_at_coordinate(x, y)
      if old_tile.is_a? AnimatedTile
        @animated_tiles.delete old_tile
      end

      grid_x, grid_y = (x / Tile::WIDTH).floor, (y / Tile::HEIGHT).floor
      tile = type.new(self, grid_x, grid_y)
      @tiles[grid_y][grid_x] = tile

      ([tile] + tile.adjacent_tiles(directions: :orthogonal)).each(&:render_edges)

      if tile.is_a? AnimatedTile
        @animated_tiles << tile
      else
        splice tile.image, tile.x, tile.y
      end

      tile
    end
  end
end
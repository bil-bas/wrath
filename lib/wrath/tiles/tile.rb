module Wrath
class Tile < GameObject
  include Log

  HEIGHT = 8
  WIDTH = 8
  SPRITE_SHEET_COLUMNS = 8

  ADJACENT_OFFSETS = [
      [-1, -1], [ 0, -1], [ 1, -1],
      [-1,  0],           [ 1,  0],
      [-1,  1], [ 0,  1], [ 1,  1]
  ]
  ADJACENT_OFFSETS_ORTHOGONAL = [[0, -1], [1, 0], [0, 1], [-1, 0]] # Top/right/bottom/left.
  ADJACENT_OFFSETS_DIAGONAL = ADJACENT_OFFSETS - ADJACENT_OFFSETS_ORTHOGONAL

  # Top/right/bottom/left is the same as me.
  ADJACENT_MASKS = {
    [false, false, false, false] => [0, 3],
    [false, false, false, true ] => [1, 2],
    [false, false, true , false] => [0, 2],
    [false, false, true , true ] => [0, 1],
    [false, true , false, false] => [3, 2],
    [false, true , false, true ] => [3, 3],
    [false, true , true , false] => [3, 1],
    [false, true , true , true ] => [0, 0],
    [true , false, false, false] => [2, 2],
    [true , false, false, true ] => [1, 1],
    [true , false, true , false] => [2, 3],
    [true , false, true , true ] => [1, 0],
    [true , true , false, false] => [2, 1],
    [true , true , false, true ] => [2, 0],
    [true , true , true , false] => [3, 0],
    [true , true , true , true ] => [1, 3],
  }

  attr_reader :speed, :map, :grid_x, :grid_y

  def ground_level; @ground_level; end
  def z; 0; end
  def edge_type; :soft_curve; end
  def sprite_position; self.class.const_get(:SPRITE_POSITION); end

  def initialize(map, grid_x, grid_y, options = {})
    options = {
      zorder: ZOrder::TILES,
      ground_level: 0,
      speed: 1,
      edge_type: :soft_curve,
    }.merge! options

    @map = map
    @grid_x, @grid_y = grid_x, grid_y
    @ground_level = options[:ground_level]
    @speed = options[:speed]

    @@sprites ||= SpriteSheet.new("tiles_8x8.png", HEIGHT, WIDTH, SPRITE_SHEET_COLUMNS)

    unless defined? @@soft_curve_masks
      @@soft_curve_masks = SpriteSheet.new("tile_soft_curves.png", 8, 8, 4)
      @@soft_curve_masks.each(&:refresh_cache)
      @@hard_curve_masks = SpriteSheet.new("tile_hard_curves.png", 8, 8, 4)
      @@hard_curve_masks.each(&:refresh_cache)
    end

    super(options)

    @type = options[:position]

    self.image = @@sprites[*sprite_position]
    self.x = (@grid_x + 0.5) * width
    self.y = (@grid_y + 0.5) * height
  end


  public
  def render_edges
    return if self.is_a? parent.class::DEFAULT_TILE or edge_type == :hard_corner

    self.image = edged_image(@@sprites[*sprite_position], adjacent_sameness)
  end

  protected
  def adjacent_sameness
    ADJACENT_OFFSETS_ORTHOGONAL.map do |offset_x, offset_y|
      tile = @map.tile_at_coordinate(x + WIDTH * offset_x, y + HEIGHT * offset_y)

      tile.nil? or tile.edge_type == :hard_corner or (tile.class == self.class)
    end
  end

  protected
  def edged_image(original, adjacent)
    adjacent_mask = ADJACENT_MASKS[adjacent]

    if adjacent_mask == [1, 3] # This is "full square".
      self.image = original
    else
      @@generated_tile_images ||= {}
      default_tile = parent.class::DEFAULT_TILE

      if img = @@generated_tile_images[[original, default_tile, adjacent_mask]]
        self.image = img
      else
        mask = ((edge_type == :soft_curve) ? @@soft_curve_masks : @@hard_curve_masks)[*adjacent_mask]
        masked_image = original.dup
        masked_image.each do |c, x, y|
          c[3] = mask.get_pixel(x, y)[3]
        end

        generated_image = @@sprites[*default_tile::SPRITE_POSITION].dup
        generated_image.splice masked_image, 0, 0, alpha_blend: true

        @@generated_tile_images[[original, default_tile, adjacent_mask]] = generated_image

        generated_image
      end
    end
  end

  public
  def touched_by(object)
    self
  end

  public
  def adjacent_tiles(options = {})
    options = {
        directions: :all,
    }.merge! options

    offsets = case options[:directions]
                when :orthogonal
                   ADJACENT_OFFSETS_ORTHOGONAL
                when :diagonal
                  ADJACENT_OFFSETS_DIAGONAL
                when :all
                  ADJACENT_OFFSETS
                else
                  raise "Bad :directions, #{options[:directions]}"
              end

    tiles = []

    offsets.each do |offset_x, offset_y|
      tile = @map.tile_at_coordinate(x + WIDTH * offset_x, y + HEIGHT * offset_y)
      tiles << tile unless tile.nil?
    end

    tiles
  end
end
end
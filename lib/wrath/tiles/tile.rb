module Wrath
class Tile < GameObject
  include Log

  HEIGHT = 8
  WIDTH = 8
  SPRITE_SHEET_COLUMNS = 8

  ADJACENT_OFFSETS = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
  ]
  ADJACENT_OFFSETS_ORTHOGONAL = [[-1, 0], [1, 0], [0, 1], [0, -1]]
  ADJACENT_OFFSETS_DIAGONAL = ADJACENT_OFFSETS - ADJACENT_OFFSETS_ORTHOGONAL

  attr_reader :speed, :contents

  def ground_level; @ground_level; end
  def z; 0; end

  def sprite_position; self.class.const_get(:SPRITE_POSITION); end

  def initialize(options = {})
    options = {
      zorder: ZOrder::TILES,
      ground_level: 0,
      speed: 1,
    }.merge! options

    @ground_level = options[:ground_level]
    @speed = options[:speed]

    @@sprites ||= SpriteSheet.new("tiles_8x8.png", HEIGHT, WIDTH, SPRITE_SHEET_COLUMNS)

    super

    @type = options[:position]

    self.image = @@sprites[*sprite_position]
    self.x = (options[:grid][0] + 0.5) * width
    self.y = (options[:grid][1] + 0.5) * height
  end

  def touched_by(object)
    self
  end

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
      tile = parent.tile_at_coordinate(x + WIDTH * offset_x, y + HEIGHT * offset_y)
      tiles << tile unless tile.nil?
    end

    tiles
  end
end
end
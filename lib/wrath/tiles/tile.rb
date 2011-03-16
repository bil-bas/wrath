module Wrath
class Tile < GameObject
  SPRITE_WIDTH = SPRITE_HEIGHT = 8

  SPRITE_SHEET_COLUMNS = 8

  VERTICAL_SCALE = 0.75

  HEIGHT = SPRITE_HEIGHT * VERTICAL_SCALE
  WIDTH = SPRITE_WIDTH

  attr_reader :speed, :contents

  def ground_level; @ground_level; end

  def sprite_position; self.class.const_get(:SPRITE_POSITION); end

  def initialize(options = {})
    options = {
      zorder: ZOrder::TILES,
      factor_y: VERTICAL_SCALE,
      ground_level: 0,
      speed: 1,
    }.merge! options

    @ground_level = options[:ground_level]
    @speed = options[:speed]

    @@sprites ||= SpriteSheet.new("tiles_8x8.png", SPRITE_WIDTH, SPRITE_HEIGHT, SPRITE_SHEET_COLUMNS)

    super

    @type = options[:position]

    self.image = @@sprites[*sprite_position]
    self.x = (options[:grid][0] + 0.5) * WIDTH
    self.y = (options[:grid][1] + 0.5) * HEIGHT
  end

  def touched_by(object)
    self
  end
end
end
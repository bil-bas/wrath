module Wrath
class Tile < GameObject
  include Log

  HEIGHT = 8
  WIDTH = 8
  SPRITE_SHEET_COLUMNS = 8

  attr_reader :speed, :contents

  def ground_level; @ground_level; end

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

  def draw
    super
  end
end
end
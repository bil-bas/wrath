class Tile < GameObject
  WIDTH = HEIGHT = 8
  VERTICAL_SCALE = 0.75

  def sprite_position; self.class.const_get(:SPRITE_POSITION); end

  def initialize(options = {})
    options = {
      zorder: ZOrder::TILES,
      factor_y: VERTICAL_SCALE,
    }.merge! options

    @@sprites ||= SpriteSheet.new("tiles_8x8.png", WIDTH, HEIGHT, 8)

    super

    @type = options[:position]

    self.image = @@sprites[*sprite_position]
    self.x = (options[:grid][0] + 0.5) * WIDTH
    self.y = (options[:grid][1] + 0.5) * HEIGHT * VERTICAL_SCALE
  end
end
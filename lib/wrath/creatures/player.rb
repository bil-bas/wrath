# encoding: utf-8

require_relative 'creature'

class Player < Creature
  attr_reader :speed, :favor, :health
  attr_writer :favor, :health # TODO: hook into these values changing.

  STATUS_COLOR = Color.rgba(255, 255, 255, 150)

  def initialize(image_row, options = {})
    options = {
      speed: 0.5,
      favor: 10,
      health: 100,
      gui_pos: [10, 110]
    }.merge! options

    @speed = options[:speed]
    @favor = options[:favor]
    @health = options[:health]
    @gui_pos = options[:gui_pos]

    @sparkle = GameObject.new(image: SpriteSheet.new("objects.png", 8, 8, 4)[1, 2])
    @sparkle.alpha = 150

    @font = Font[8]

    super(image_row, options)
  end

  def draw
    super

    sparkle_factor = (favor / 200.0) - @sparkle.factor
    @sparkle.draw_relative(x + 3.5 * factor_x, y - height, y, - milliseconds / 10.0, 0, 0, sparkle_factor, sparkle_factor)

    @font.draw "F: #{@favor} H: #{@health}", *@gui_pos, ZOrder::GUI, 1, 1, STATUS_COLOR
  end
end
# encoding: utf-8

require_relative 'creature'

class Player < Creature
  CARRY_OFFSET = 6
  STATUS_COLOR = Color.rgba(255, 255, 255, 150)

  attr_reader :speed, :favor, :health
  attr_writer :favor, :health # TODO: hook into these values changing.

  def initialize(options = {})
    options = {
      speed: 0.5,
      favor: 10,
      health: 100,
    }.merge! options

    @speed = options[:speed]
    @favor = options[:favor]
    @health = options[:health]
    @gui_pos = options[:gui_pos]

    @carrying = nil

    @sparkle_frames = Animation.new(file: "sparkle_8x8.png")
    @sparkle = GameObject.new(image: @sparkle_frames[1])
    @sparkle.alpha = 150

    @font = Font[8]

    super(options)
  end

  def draw
    super

    sparkle_factor = (favor / 200.0) - @sparkle.factor
    @sparkle.draw_relative(x + 3.5 * factor_x, y - height, y, - milliseconds / 10.0, 0, 0, sparkle_factor, sparkle_factor)

    @font.draw "F: #{@favor} H: #{@health}", *@gui_pos, ZOrder::GUI, 1, 1, STATUS_COLOR
  end


end
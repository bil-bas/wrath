# encoding: utf-8

class Player < Creature
  CARRY_OFFSET = 6
  STATUS_COLOR = Color.rgba(255, 255, 255, 150)
  FAVOR_TO_WIN = 100
  MAX_HEALTH = 100

  attr_reader :speed, :favor, :health, :carrying
  attr_writer :carrying # TODO: hook into these values changing.

  def carrying?; not @carrying.nil?; end
  def empty_handed?; @carrying.nil?; end
  def can_be_activated?(actor); false; end

  def initialize(options = {})
    options = {
      speed: 2,
      favor: 0,
      health: 100,
    }.merge! options

    @speed = options[:speed]
    @favor = options[:favor]
    @health = options[:health]
    @gui_pos = options[:gui_pos]

    @carrying = nil

    @animation_file = options[:animation]

    @font = Font[8]

    super(options)
  end

  def alive?; health > 0; end
  def dead?; health <= 0; end

  def die!
    self.health = 0
    super
  end

  def favor=(value)
    original_favor = @favor
    @favor = [[value, 0].max, FAVOR_TO_WIN].min
    parent.win!(self) if @favor == FAVOR_TO_WIN and original_favor > 0

    @favor
  end

  def health=(value)
    original_health = @health
    @health = [[value, 0].max, MAX_HEALTH].min
    die! if @health == 0 and original_health > 0

    @health
  end

  def recreate_options
    {
        animation: @animation_file,
        gui_pos: @gui_pos,
        local: remote?, # Invert locality of player created on client.
        number: number
    }.merge! super
  end

  def draw
    super

    @font.draw "F: #{@favor.to_i} H: #{@health.to_i}", *@gui_pos, ZOrder::GUI, 1, 1, STATUS_COLOR
  end
end
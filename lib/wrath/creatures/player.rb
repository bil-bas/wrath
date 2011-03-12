# encoding: utf-8

class Player < Creature
  STATUS_COLOR = Color.rgba(255, 255, 255, 150)
  FAVOR_TO_WIN = 100
  MAX_HEALTH = 100
  WOUND_FLASH_PERIOD = 200
  AFTER_WOUND_FLASH_DURATION = 100

  attr_reader :speed, :favor, :health, :carrying
  attr_writer :carrying # TODO: hook into these values changing.

  def can_pick_up?; false; end
  def carrying?; not @carrying.nil?; end
  def empty_handed?; @carrying.nil?; end
  def can_be_activated?(actor); false; end

  def initialize(options = {})
    options = {
      speed: 2,
      favor: 0,
      health: MAX_HEALTH,
    }.merge! options

    @speed = options[:speed]
    @favor = options[:favor]
    @health = options[:health]
    @gui_pos = options[:gui_pos]

    @carrying = nil

    @animation_file = options[:animation]

    @font = Font[8]

    @first_wounded_at = @last_wounded_at = nil

    super(options)
  end

  def alive?; health > 0; end
  def dead?; health <= 0; end

  def die!
    self.color.blue = self.color.green = 255
    self.health = 0
    super
  end

  def favor=(value)
    @favor = [[value, 0].max, FAVOR_TO_WIN].min
    parent.win!(self) if @favor == FAVOR_TO_WIN and not parent.winner

    @favor
  end

  def health=(value)
    original_health = @health
    @health = [[value, 0].max, MAX_HEALTH].min
    if @health == 0 and original_health > 0 and not parent.winner
      parent.lose!(self)
    end

    if @health < original_health
      @last_wounded_at = milliseconds
      @first_wounded_at = @last_wounded_at unless @first_wounded_at
    end

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

  def update
    super

    # Reset colour if it was a while since we were wounded.
    if @first_wounded_at
      if milliseconds - @last_wounded_at > AFTER_WOUND_FLASH_DURATION
        self.color.blue = self.color.green = 255
        @first_wounded_at = @last_wounded_at = nil
      else
        if (milliseconds - @first_wounded_at).div(WOUND_FLASH_PERIOD) % 2 == 0
          self.color.blue = self.color.green = 100
        else
          self.color.blue = self.color.green = 255
        end
      end
    end
  end
end
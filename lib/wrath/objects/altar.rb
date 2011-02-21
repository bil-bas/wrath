# encoding: utf-8

require_relative 'static_object'

class Altar < StaticObject
  IMAGE_POS = [0, 1]
  trait :timer

  CLEAR_DELAY = 25

  def ready?; @blood == 0; end

  def initialize(options = {})
    options = {
      x: 80,
      y: 60,
    }.merge! options

    @blood = 0
    @player = nil
    @sacrifice = nil

    super(IMAGE_POS, options)
  end

  def sacrifice(player, sacrifice)
    @blood = 100
    @player = player
    @sacrifice = sacrifice
    @sacrifice.sacrificed
    after(CLEAR_DELAY) { clear_blood }
  end

  def draw
    super

    unless ready?
      @@sprites[1, 1].draw(x - 3.5, y - 8, zorder + y, 1, 1, Color.rgba(255, 255, 255, @blood + 100))
      @sacrifice.image.draw(x - @sacrifice.image.width / 2, y - (height * 1.5) + (@blood - 100) / 10.0, zorder + y, 1, 1, Color.rgba(230, 230, 255, @blood + 25))
    end
  end

  def clear_blood
    if @blood > 0
      @blood -= 1
      @player.favor += @sacrifice.favor / 10 if @blood % 10 == 0
    end

    if ready?
      @sacrifice.ghost_disappeared
    else
      after(CLEAR_DELAY) { clear_blood }
    end
  end
end
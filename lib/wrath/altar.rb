# encoding: utf-8

require_relative 'wrath_object'

class Altar < WrathObject
  trait :timer

  CLEAR_DELAY = 25

  def ready?; @blood == 0; end

  def initialize(options = {})
    options = {
      image: $window.furniture_sprites[1, 1],
      x: 80,
      y: 60,
    }.merge! options

    @blood = 0

    super(options)
  end

  def sacrifice(object)
    @blood = 100
    @ghost_image = object.image
    after(CLEAR_DELAY) { clear_blood }
    object.destroy
  end

  def draw
    super

    unless ready?
      $window.pixel.draw(x - 2, y - 6, zorder + y, 4, 6, Color.rgba(255, 0, 0, @blood + 100))
      @ghost_image.draw(x - @ghost_image.width / 2, y - (height * 1.5) + (@blood - 100) / 10.0, zorder + y, 1, 1, Color.rgba(230, 230, 255, @blood + 25))
    end
  end

  def clear_blood
    if @blood > 0
      @blood -= 1
    end

    unless ready?
      after(CLEAR_DELAY) { clear_blood }
    end
  end
end
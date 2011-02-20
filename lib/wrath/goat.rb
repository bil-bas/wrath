# encoding: utf-8

require_relative 'carriable'

class Goat < WrathObject
  include Carriable

  trait :timer

  def initialize(options = {})
    options = {
      image: $window.character_sprites[13, 2],
      speed: 0.5,
    }.merge! options

    @speed = options[:speed]

    super(options)

    after(800 + (rand(400) + rand(400))) { jump }
  end

  def jump
    if @z == 0 and not carried?
      @z_velocity = 0.4 + rand(0.1)
      angle = rand(360)
      @y_velocity = Math::sin(angle) * 0.5
      @x_velocity = Math::cos(angle) * 0.5
    end

    after(800 + (rand(400) + rand(400))) { jump }
  end
end
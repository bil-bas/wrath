# encoding: utf-8

require_relative '../carriable'

class Mob < WrathObject
  include Carriable

  trait :timer

  def initialize(options = {})
    options = {
    }.merge! options

    @speed = options[:speed]

    super(options)

    after(800 + (rand(400) + rand(400))) { jump }
  end

  def jump
    if @z == 0 and not carried?
      @z_velocity = 0.4 + rand(0.1)
      angle = rand(360)
      @y_velocity = Math::sin(angle) * @speed
      @x_velocity = Math::cos(angle) * @speed
    end

    after(800 + (rand(400) + rand(400))) { jump }
  end

  def sacrificed
    destroy
  end

  def ghost_disappeared

  end
end
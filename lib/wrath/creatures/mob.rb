# encoding: utf-8

require_relative 'creature'
require_relative '../carriable'

class Mob < Creature
  include Carriable

  trait :timer

  def initialize(options = {})
    options = {
    }.merge! options

    @speed = options[:speed]
    @vertical_jump = options[:vertical_jump]
    @horizontal_jump = options[:horizontal_jump]
    @jump_delay = options[:jump_delay]

    super(options)

    unless @remote
      after(@jump_delay + (rand(@jump_delay / 2) + rand(@jump_delay / 2))) { jump }
    end
  end

  def jump
    if @z == 0 and not carried?
      @z_velocity = @vertical_jump + rand(@vertical_jump / 2.0)
      angle = rand(360)
      @y_velocity = Math::sin(angle) * @horizontal_jump
      @x_velocity = Math::cos(angle) * @horizontal_jump
    end

    after(@jump_delay + (rand(@jump_delay / 2.0) + rand(@jump_delay / 2.0))) { jump }
  end

  def sacrificed(player, altar)
    ((favor / 10) + 4).times do
      angle = rand(360)
      speed = 0.02 + rand(0.05)
      y_velocity = Math::sin(angle) * speed
      x_velocity = Math::cos(angle) * speed
      z_velocity = -0.1 + rand(0.2)
      Blood.create(x: altar.x, y: altar.y, z: altar.z + altar.height,
        x_velocity: x_velocity, y_velocity: y_velocity, z_velocity: z_velocity)
    end

    super
  end

  def ghost_disappeared

  end
end
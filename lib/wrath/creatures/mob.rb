# encoding: utf-8

require_relative 'creature'
require_relative '../carriable'

class Mob < Creature
  include Carriable

  trait :timer

  def initialize(image_row, options = {})
    options = {
    }.merge! options

    @speed = options[:speed]
    @vertical_jump = options[:vertical_jump]
    @horizontal_jump = options[:horizontal_jump]
    @jump_delay = options[:jump_delay]

    super(image_row, options)

    after(@jump_delay + (rand(@jump_delay / 2) + rand(@jump_delay / 2))) { jump }
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

  def sacrificed
    destroy
  end

  def ghost_disappeared

  end
end
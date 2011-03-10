# encoding: utf-8

class Mob < Creature

  EXPLOSION_H_SPEED = 0.02..0.07
  EXPLOSION_Z_VELOCITY = -0.1..0.3

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

    @sacrificial_explosion = Explosion.new(type: Blood, number: ((favor / 10) + 4), h_speed: EXPLOSION_H_SPEED,
                                            z_velocity: EXPLOSION_Z_VELOCITY)

    if local?
      after(@jump_delay + (rand(@jump_delay / 2) + rand(@jump_delay / 2))) { jump }
    end
  end

  def jump
    if @z <= ground_level and not carried?
      @z_velocity = @vertical_jump + rand(@vertical_jump / 2.0)
      angle = rand(360)
      @y_velocity = Math::sin(angle) * @horizontal_jump * 2
      @x_velocity = Math::cos(angle) * @horizontal_jump * 2
    end

    after(@jump_delay + (rand(@jump_delay / 2.0) + rand(@jump_delay / 2.0))) { jump }
  end

  def sacrificed(player, altar)
    super
  end

  def ghost_disappeared

  end
end
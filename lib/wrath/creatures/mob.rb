# encoding: utf-8

class Mob < Creature
  EXPLOSION_H_SPEED = 0.02..0.07
  EXPLOSION_Z_VELOCITY = -0.1..0.3

  trait :timer

  def initialize(options = {})
    options = {
    }.merge! options

    @speed = options[:speed]
    @vertical_jump = options[:vertical_jump]
    @horizontal_jump = options[:horizontal_jump]
    @jump_delay = options[:jump_delay]

    super(options)

    @sacrificial_explosion = Explosion.new(parent, type: Blood, number: ((favor / 10) + 4), h_speed: EXPLOSION_H_SPEED,
                                            z_velocity: EXPLOSION_Z_VELOCITY)

    schedule_jump if local?
  end

  def jump
    if @z <= ground_level and @state == :standing
      @z_velocity = @vertical_jump + rand(@vertical_jump / 2.0)
      angle = rand(360)
      @y_velocity = Math::sin(angle) * @horizontal_jump * 2
      @x_velocity = Math::cos(angle) * @horizontal_jump * 2
    else
      schedule_jump
    end
  end

  def schedule_jump
    after(@jump_delay + (rand(@jump_delay / 2.0) + rand(@jump_delay / 2.0)), name: :jump) { jump }
  end

  def on_stopped
    schedule_jump
    super
  end

  def pick_up(by)
    stop_timer(:jump)
    super(by)
  end

  def sacrificed(player, altar)
    super
  end

  def ghost_disappeared

  end
end
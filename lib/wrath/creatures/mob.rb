module Wrath

class Mob < Creature
  trait :timer

  def initialize(options = {})
    options = {
    }.merge! options

    @vertical_jump = options[:vertical_jump]
    @horizontal_jump = options[:horizontal_jump]
    @jump_delay = options[:jump_delay]

    super(options)

    schedule_jump if local?
  end

  def die!
    stop_timer(:jump)
    super
  end

  def jump
    if @z <= ground_level and @state == :standing and local?
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
    stop_timer(:jump)
    schedule_jump unless dead?
    super
  end
end
end
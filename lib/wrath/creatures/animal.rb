module Wrath

# Animals are any sort of non-intelligent creatures. They move by bouncing around.

class Animal < Creature
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
    self.facing = rand(360)
    if @z <= ground_level and @state == :standing and local?
      @z_velocity = @vertical_jump + rand(@vertical_jump / 2.0)
      @y_velocity = Math::sin(facing) * @horizontal_jump * 2
      @x_velocity = Math::cos(facing) * @horizontal_jump * 2
    else
      schedule_jump
    end
  end

  def schedule_jump
    after(@jump_delay + (rand(@jump_delay / 2.0) + rand(@jump_delay / 2.0)), name: :jump) { jump }
  end

  def on_wounded
    # Try to move away from pain.
    if timer_exists? :jump
      stop_timer(:jump)
      jump
    end
  end

  def on_stopped
    stop_timer(:jump)
    schedule_jump unless dead?
    super
  end

  public
  def on_collision(other)
    case other
      when Wall
        # Everything, except carrued objects, hit walls.
        collides = (not (can_pick_up? and inside_container?))

        # Bounce back from the edge of the screen
        if collides and not controlled_by_player? and (empty_handed? or not contents.controlled_by_player?)
          case other.side
            when :right
              self.x_velocity = - self.x_velocity * elasticity * 0.5 if x_velocity > 0
            when :left
              self.x_velocity = - self.x_velocity * elasticity * 0.5 if x_velocity < 0
            when :top
              self.y_velocity = - self.y_velocity * elasticity * 0.5 if y_velocity < 0
            when :bottom
              self.y_velocity = - self.y_velocity * elasticity * 0.5 if y_velocity > 0
            else
              raise "bad side"
          end
        end

        collides

      else
        super
    end
  end
end
end
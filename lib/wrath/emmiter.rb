# Emits particles.
class Emitter
  def initialize(type, parent, options = {})
    options = {
        h_speed: 1..2,
        z_velocity: 0.5..1,
        number: 1,
    }.merge! options

    @parent, @type = parent, type
    @number = options[:number]
    @h_speed = options[:h_speed]
    @z_velocity = options[:z_velocity]
  end

  public
  # Emit a number of particle.
  def emit(position, options = {})
    number = options[:number] || @number

    random(number).times do
      angle = rand(360)
      speed = random(@h_speed)
      y_velocity = Math::sin(angle) * speed
      x_velocity = Math::cos(angle) * speed
      @type.create(parent: @parent, position: position,
        velocity: [x_velocity, y_velocity, random(@z_velocity)])
    end

    nil
  end

  protected
  # Chooses a random number within a range, or just returns a scalar passed to it.
  def random(value)
    case value
      when Range
        value.min + rand(value.max - value.min)
      else
        value
    end
  end
end
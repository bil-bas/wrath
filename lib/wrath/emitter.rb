module Wrath
# Emits particles.
class Emitter
  include Log

  def initialize(type, parent, options = {})
    options = {
        h_speed: 0.3..0.5,
        z_velocity: 0.5..0.9,
        number: 1,
    }.merge! options

    @parent, @type = parent, type
    @number = options[:number]
    @h_speed = options[:h_speed]
    @z_velocity = options[:z_velocity]
  end

  public
  # Emit a number of particle.
  # @option options [Array<BaseObject>] thrown_by ([]) Object or objects that will not collide with the particles generated
  def emit(position, options = {})
    options = {
        number: @number,
        thrown_by: [],
    }.merge! options

    number = options[:number]
    thrown_by = Array(options[:thrown_by])

    random(number).round.times do
      angle = rand(360)
      speed = random(@h_speed)
      y_velocity = offset_x(angle, speed)
      x_velocity = offset_y(angle, speed)
      @type.create(parent: @parent, position: position, thrown_by: thrown_by,
        velocity: [x_velocity, y_velocity, random(@z_velocity)])
    end

    nil
  end

  protected
  # Chooses a random number within a range, or just returns a scalar passed to it.
  def random(value)
    case value
      when Range
        if value.max.is_a? Integer and value.min.is_a? Integer
          value.min + rand(value.max - value.min)
        else
          value.min + rand() * (value.max - value.min)
        end
      else
        value
    end
  end
end
end
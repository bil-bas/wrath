class Explosion
  def random(value)
    case value
      when Range
        value.min + rand(value.max - value.min)
      else
        value
    end
  end

  def initialize(parent, options = {})
    @parent = parent
    @type = options[:type]
    @number = options[:number]
    @h_speed = options[:h_speed]
    @z_velocity = options[:z_velocity]
  end

  def blast(x, y, z)
    random(@number).times do
      angle = rand(360)
      speed = random(@h_speed)
      y_velocity = Math::sin(angle) * speed
      x_velocity = Math::cos(angle) * speed
      @type.create(parent: @parent, position: [x, y, z],
        velocity: [x_velocity, y_velocity, random(@z_velocity)])
    end
  end
end
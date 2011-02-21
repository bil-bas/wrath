module Carriable
  def carriable?; true; end
  def carried?; not @carrier.nil?; end
  def affected_by_gravity?; @carrier.nil?; end

  attr_reader :encumbrance

  def initialize(image_row, options = {})
    options = {
        encumbrance: 0.2,
    }.merge! options

    @encumbrance = options[:encumbrance]

    @carrier = nil

    super image_row, options
  end

  def pick_up(carrier, z)
    @carrier = carrier
    @z = z

    nil
  end

  def drop(x_velocity = 0, y_velocity = 0, z_velocity = 0)
    @x_velocity, @y_velocity, @z_velocity = x_velocity, y_velocity, z_velocity
    @carrier = nil

    nil
  end

  def update
    if carried?
      self.x, self.y = @carrier.x, @carrier.y
    end

    super
  end
end
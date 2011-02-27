module Carriable
  def carriable?; true; end
  def carried?; not @carrier.nil?; end
  def affected_by_gravity?; @carrier.nil?; end

  def can_be_activated?(actor)
    carriable? and actor.empty_handed?
  end

  def activate(actor)
    actor.pick_up(self)
  end

  attr_reader :encumbrance

  def initialize(options = {})
    options = {
        encumbrance: 0.2,
    }.merge! options

    @encumbrance = options[:encumbrance]

    @carrier = nil
    @z_offset = 0

    super options
  end

  def pick_up(carrier, z_offset)
    @carrier = carrier
    @z_offset = z_offset

    nil
  end

  def drop(player, x_velocity = 0, y_velocity = 0, z_velocity = 0)
    @x_velocity, @y_velocity, @z_velocity = x_velocity, y_velocity, z_velocity
    @carrier = nil

    nil
  end

  def put_into(container)
    @carrier = nil

    nil
  end

  def update
    if carried?
      self.x, self.y, self.z = @carrier.x, @carrier.y, @carrier.z + @z_offset
    end

    super
  end
end
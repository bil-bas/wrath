class Carriable < WrathObject
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
        z_offset: 0,
    }.merge! options

    @encumbrance = options[:encumbrance]
    @z_offset = options[:z_offset]

    @carrier = nil

    super options
  end

  def pick_up(carrier)
    @carrier = carrier
    self.velocity = [0, 0, 0]

    nil
  end

  def drop(player, x_velocity = 0, y_velocity = 0, z_velocity = 0)
    self.velocity = [x_velocity, y_velocity, z_velocity]
    @carrier = nil

    nil
  end

  def put_into(container)
    @carrier = nil

    nil
  end

  def update
    if carried?
      self.position = [@carrier.x, @carrier.y + 0.001, @carrier.z + @carrier.height + @z_offset]
    end

    super
  end
end
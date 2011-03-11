class Carriable < WrathObject

  attr_reader :carrier, :thrown_by
  def can_drop?; true; end
  def can_pick_up?; true; end
  def carried?; not @carrier.nil?; end
  def affected_by_gravity?; @carrier.nil?; end

  def can_be_activated?(actor)
    can_pick_up? and actor.empty_handed?
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
    @thrown_by = nil

    super options
  end

  def picked_up(carrier)
    @carrier = carrier
    self.velocity = [0, 0, 0]

    nil
  end

  def on_stopped
    super
    @thrown_by = nil
  end

  def dropped(player, x_velocity = 0, y_velocity = 0, z_velocity = 0)
    self.velocity = [x_velocity, y_velocity, z_velocity]
    @thrown_by = @carrier
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
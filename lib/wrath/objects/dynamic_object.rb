module Wrath
class DynamicObject < BaseObject
  attr_reader :carrier, :thrown_by, :z_offset

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
    @thrown_by = [] # These will be immune from colliding with the object.

    super options
  end

  def picked_up(carrier)
    @carrier = carrier
    self.velocity = [0, 0, 0]

    nil
  end

  def on_stopped
    super
    @thrown_by.clear
  end

  def dropped(player, x_velocity = 0, y_velocity = 0, z_velocity = 0)
    self.velocity = [x_velocity, y_velocity, z_velocity]
    @thrown_by = [@carrier]
    @carrier = nil

    nil
  end

  def put_into(container)
    @carrier = nil

    nil
  end

  # Called from teh game-state, once all updates are complete, to ensure syncing between carried objects.
  def update_carried_position
    self.position = [@carrier.x, @carrier.y + 0.001, @carrier.z + @carrier.height + z_offset]
  end
end
end
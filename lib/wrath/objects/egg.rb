module Wrath
class Egg < DynamicObject
  trait :timer

  GESTATION_DELAY = 3 * 1000

  def can_knock_down_creature?(creature); false; end

  def initialize(options = {})
    options = {
      favor: 1,
      encumbrance: 0,
      elasticity: 0.4,
      factor: 0.7,
      z_offset: 0,
      animation: "egg_4x5.png",
    }.merge! options

    super options
  end

  def on_stopped
    super
    after(GESTATION_DELAY, name: :gestation) { hatch } unless parent.client?
  end

  def on_being_picked_up(container)
    super(container)
    stop_timer(:gestation)
  end

  def hatch
    Chicken.create(position: position, parent: parent, z_velocity: 0.5)
    destroy
  end

  def on_collision(other)
    case other
      when Humanoid
        if not thrown_by.include? other and (not inside_container?) and z > ground_level
          destroy
          other.pick_up(BrokenEgg.create(parent: parent))
        end
    end

    super(other)
  end
end
end
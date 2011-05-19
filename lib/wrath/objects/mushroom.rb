module Wrath
class Mushroom < DynamicObject
  POISON_DURATION = 4000

  def initialize(options = {})
    options = {
      favor: 2,
      factor: 0.7,
      encumbrance: 0.1,
      elasticity: 0,
      z_offset: 0,
      animation: "mushroom_6x5.png",
    }.merge! options

    super options
  end

  def on_collision(other)
    case other
      when Creature
        if not thrown_by.include? other and (not inside_container?) and z > ground_level
          other.apply_status(:poisoned, duration: POISON_DURATION)
          destroy
        end
    end

    super(other)
  end
end
end
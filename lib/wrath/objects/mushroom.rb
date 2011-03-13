class Mushroom < Carriable
  POISON_DURATION = 4000

  def initialize(options = {})
    options = {
      favor: 1,
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
        if thrown_by != other and (not carried?) and z > ground_level
          other.poison(POISON_DURATION)
          destroy
        end
    end

    super(other)
  end
end
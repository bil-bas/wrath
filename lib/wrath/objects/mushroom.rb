class Mushroom < Carriable
  def initialize(options = {})
    options = {
      factor: 0.7,
      encumbrance: 0.1,
      elasticity: 0,
      z_offset: 0,
      animation: "mushroom_6x5.png",
      collision_type: :scenery,
    }.merge! options

    super options
  end
end
class Egg < Carriable
  trait :timer

  def initialize(options = {})
    options = {
      encumbrance: 0,
      elasticity: 0.4,
      factor: 0.7,
      z_offset: 0,
      animation: "egg_4x5.png",
    }.merge! options

    super options
  end
end
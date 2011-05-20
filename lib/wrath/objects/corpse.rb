module Wrath
class Corpse < DynamicObject
  # Corpses are created from the Creature#die! method, simultaneously on all machines.
  def network_create?; false; end

  def initialize(options = {})
    options = {
        favor: 2,
        elasticity: 0,
        sacrifice_particle: BloodDroplet,
    }.merge! options

    super(options)
  end
end
end
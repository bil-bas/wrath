module Wrath
class Corpse < Carriable
  # Corpses are created from the Creature#die! method, simultaneously on all machines.
  def network_create?; false; end

  def initialize(options = {})
    options = {
        favor: 1,
        elasticity: 0,
    }.merge! options

    @sacrificial_explosion = options[:emitter]

    super(options)
  end
end
end
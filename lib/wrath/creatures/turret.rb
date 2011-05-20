module Wrath
  class Turret < Animal
    public
    def initialize(options = {})
      options = {
        favor: 6,
        health: 10,
        encumbrance: 0.2,
        z_offset: -2,
        animation: "turret_6x6.png",
        sacrifice_particle: Spark,
      }.merge! options

      super(options)
    end

    def schedule_jump
      # Do nothing.
    end
  end
end
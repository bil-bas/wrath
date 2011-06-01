module Wrath
  class Parrot < Animal
    def initialize(options = {})
      options = {
          flying_height: 4,
          health: 10,
          favor: 4,
          walk_duration: 3000,
          move_interval: 0,
          speed: 1.25,
          move_type: :walk,
          elasticity: 0.5,
          encumbrance: 0.1,
          animation: "parrot_8x8.png",
          factor: 0.7,
      }.merge! options

      super(options)
    end
  end
end
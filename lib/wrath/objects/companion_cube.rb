module Wrath
  class CompanionCube < DynamicObject
    def initialize(options = {})
      options = {
        favor: 6,
        encumbrance: 0.6,
        elasticity: 0.4,
        z_offset: -2,
        animation: "companion_cube_7x7.png",
      }.merge! options

      super options
    end
  end
end
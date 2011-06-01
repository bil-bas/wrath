module Wrath
  class Pearl < DynamicObject
    def initialize(options = {})
      options = {
          animation: "pearl_7x7.png",
          factor: 0.75,
          favor: 8,
          elasticity: 0.2,
          encumbrance: 0.2,
          z_offset: -1,
      }.merge! options

      super(options)
    end
  end
end
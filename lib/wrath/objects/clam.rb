module Wrath
  class Clam < Chest
    def initialize(options = {})
      options = {
          animation: "clam_12x13.png",
          elasticity: 0.2,
          contents: Pearl,
          encumbrance: 0.4,
          z_offset: -2,
      }.merge! options

      super(options)
    end
  end
end
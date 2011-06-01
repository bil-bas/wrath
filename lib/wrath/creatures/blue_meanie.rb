module Wrath
  class BlueMeanie < Humanoid
    def initialize(options = {})
      options = {
          favor: 8,
          health: 20,
          flying_height: 4,
          move_interval: 0,
          encumbrance: 0.3,
          animation: "blue_meanie_10x8.png",
      }.merge! options

      super(options)
    end
  end
end
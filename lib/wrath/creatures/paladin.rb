module Wrath
  class Paladin < Knight
    DAMAGE = 20

    def initialize(options = {})
      options = {
          damage_per_hit: DAMAGE,
          favor: 15,
          health: 70,
          animation: "paladin_8x8.png",
      }.merge! options

      super options
    end
  end
end
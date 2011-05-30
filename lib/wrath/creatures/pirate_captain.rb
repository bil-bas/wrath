module Wrath
  class PirateCaptain < Pirate
    DAMAGE = 15

    def initialize(options = {})
      options = {
          favour: 12,
          health: 50,
          damage_per_hit: DAMAGE,
          animation: "pirate_captain_8x8.png",
      }.merge! options

      super options
    end
  end
end
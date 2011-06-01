module Wrath
  class PirateCaptain < Pirate
    DAMAGE = 25

    def initialize(options = {})
      options = {
          favour: 12,
          health: 50,
          damage_per_hit: DAMAGE,
          speed: 0.8,
          walk_duration: 1000,
          animation: "pirate_captain_8x8.png",
      }.merge! options

      super options
    end
  end
end
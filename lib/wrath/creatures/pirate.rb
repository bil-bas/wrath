module Wrath
  class Pirate < Humanoid
    DAMAGE = 10

    def hurts?(other); other.controlled_by_player?; end

    def initialize(options = {})
      options = {
          favor: 10,
          health: 30,
          damage_per_hit: DAMAGE,
          animation: "pirate_8x8.png",
      }.merge! options

      super options
    end
  end
end
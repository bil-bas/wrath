module Wrath
  class Knight < Humanoid
    DAMAGE = 10

    def hurts?(other); other.controlled_by_player?; end

    def initialize(options = {})
      options = {
          damage_per_hit: DAMAGE,
          favor: 12,
          health: 40,
          elasticity: 0.1,
          encumbrance: 0.5,
          animation: "knight_8x8.png",
      }.merge! options

      super options
    end
  end
end
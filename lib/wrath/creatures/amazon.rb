module Wrath
  class Amazon < Humanoid
    DAMAGE = 10

    def hurts?(other); other.controlled_by_player?; end

    def initialize(options = {})
      options = {
          damage_per_hit: DAMAGE,
          favour: 10,
          health: 40,
          animation: "amazon_8x8.png",
      }.merge! options

      super options
    end
  end
end
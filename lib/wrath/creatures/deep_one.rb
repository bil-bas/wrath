module Wrath
  class DeepOne < Humanoid
    DAMAGE = 10

    def hurts?(other); other.controlled_by_player?; end

    def initialize(options = {})
      options = {
          favor: 10,
          health: 40,
          damage_per_hit: DAMAGE,
          animation: "deep_one_10x10.png",
      }.merge! options

      super options
    end
  end
end
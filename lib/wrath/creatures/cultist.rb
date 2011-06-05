module Wrath
  class Cultist < Humanoid
    DAMAGE = 10

    def hurts?(other); other.controlled_by_player?; end

    def breathes?(medium); medium == :air; end

    def initialize(options = {})
      options = {
          favour: 8,
          damage_per_hit: DAMAGE,
          animation: "cultist_8x8.png",
      }.merge! options

      super options
    end
  end
end
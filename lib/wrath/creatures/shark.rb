module Wrath
  class Shark < Animal
    DAMAGE = 20

    def hurts?(other); other.controlled_by_player?; end
    def dazed_offset_x; width * -0.375; end

    def initialize(options = {})
      options = {
          flying_height: 6,
          move_interval: 0,
          move_type: :walk,
          walk_duration: 3000,
          speed: 0.8,
          damage_per_hit: DAMAGE,
          favor: 12,
          health: 50,
          encumbrance: 0.7,
          animation: "shark_16x7.png",
      }.merge! options

      super(options)
    end
  end
end
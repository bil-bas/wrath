module Wrath
  class MiGo < Humanoid
    DAMAGE = 15
    RADIATION_HEAL = 3 / 1000.0

    def hurts?(other); other.controlled_by_player?; end

    def initialize(options = {})
      options = {
          flying_height: 4,
          move_interval: 0,
          walk_duration: 400,
          speed: 1.5,
          damage_per_hit: DAMAGE,
          favor: 12,
          health: 20,
          encumbrance: 0.8,
          animation: "mi_go_10x8.png",
      }.merge! options

      super(options)
    end

    def update
      super

      if exists? and not parent.client? and irradiated?
        self.health += RADIATION_HEAL * parent.frame_time
      end
    end
  end
end
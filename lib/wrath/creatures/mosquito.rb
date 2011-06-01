module Wrath
  class Mosquito < Animal
    DPS = 2

    def hurts?(other); not other.is_a?(Mosquito); end
    def can_be_activated?(actor); false; end

    def initialize(options = {})
      options = {
          flying_height: 3,
          damage_per_second: DPS,
          health: 50, # Difficult to kill, but not really too relevant.
          walk_duration: 200,
          move_interval: 0,
          speed: 0.5,
          move_type: :walk,
          move_interval: 0,
          animation: "mosquito_8x8.png",
      }.merge! options

      super(options)
    end

    def die!; destroy; end
  end
end
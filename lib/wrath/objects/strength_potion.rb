module Wrath
  class StrengthPotion < Potion
    DURATION = 5000

    def initialize(options = {})
      options = {
        animation: "strength_potion_6x6.png",
      }.merge! options

      super options
    end

    def affect(other)
      other.apply_status(:enlarged, duration: DURATION)
    end
  end
end
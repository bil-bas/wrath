module Wrath
  class SeaWater < Water
    ANIMATION_POSITIONS = [[0, 4], [1, 4]]

    def initialize(options = {})
      options = {
          ground_level: -1000,
      }.merge! options

      super options
    end
  end
end
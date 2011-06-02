module Wrath
  class SeaWater < Water
    ANIMATION_POSITIONS = [[0, 4], [1, 4]]

    def initialize(map, grid_x, grid_y, options = {})
      options = {
          ground_level: -1000,
          zorder: ZOrder::BACK_GLOW + 0.01, # Ensure they are just over the mast shadows and fire glows.
      }.merge! options

      super(map, grid_x, grid_y, options)
    end
  end
end
module Wrath
  class TallBlock < StaticObject
    def initialize(options = {})
      options = {
        animation: "tall_block_10x25.png",
        factor_x: 1, # All should be aligned identically.
      }.merge! options

      super options
    end
  end
end
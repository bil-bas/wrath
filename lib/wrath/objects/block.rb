module Wrath
  class Block < StaticObject
    SPRITES = {
        1 => "10x10",
        2 => "10x18",
        3 => "10x26",
    }
    def initialize(options = {})
      options = {
        animation: "block_10x10.png",
        factor_x: 1, # All should be aligned identically.
        stack: 1,
      }.merge! options

      super options

      self.image = "objects/block_#{SPRITES[options[:stack]]}.png"
    end
  end
end
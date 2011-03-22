module Wrath
  class Grog < Mushroom
    def initialize(options = {})
      options = {
        z_offset: -1,
        animation: "grog_8x7.png",
      }.merge! options

      super options
    end
  end
end
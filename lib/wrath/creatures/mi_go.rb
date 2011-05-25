module Wrath
  class MiGo < Knight
    def ground_level; super + ((@state == :thrown) ? 0 : 4); end

    def initialize(options = {})
      options = {
        favor: 12,
        health: 20,
        walk_interval: 0,
        encumbrance: 0.4,
        z_offset: -2,
        animation: "mi_go_10x8.png",
      }.merge! options

      super(options)
    end
  end
end
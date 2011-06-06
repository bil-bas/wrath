module Wrath
  class ZombiePirate < Pirate
    def initialize(options = {})
      options = {
          animation: "zombie_pirate_8x8.png",
      }.merge! options

      super options
    end
  end
end
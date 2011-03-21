module Wrath
class Pirate < Knight
  def initialize(options = {})
    options = {
        animation: "pirate_8x8.png",
    }.merge! options

    super options
  end
end
end
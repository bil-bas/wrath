module Wrath
class Pebble < Wrath::Particle
  def initialize(options = {})
    options = {
      animation: "pebble_2x2.png",
    }.merge! options

    super options
  end
end
end
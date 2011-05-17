module Wrath
class Pebble < Wrath::Particle
  def initialize(options = {})
    options = {
      animation: "pebble_2x2.png",
      elasticity: 0.2,
    }.merge! options

    super options
  end

  def on_stopped
    parent.map.splice(image, x - width / 2, y - height)
    destroy
  end
end
end
# A droplet of fluid, defaulting to being white.
module Wrath
# A particle that is just a single pixel which "stains" the ground it lands on.
class Droplet < Particle
  def initialize(options = {})
    options = {
      elasticity: 0,
      animation: "pixel_1x1.png",
    }.merge! options

    super options
  end

  def on_stopped
    parent.map.set_color(x, y, color)
    destroy
  end
end
end
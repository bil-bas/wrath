# A droplet of fluid, defaulting to being white.
module Wrath
class Droplet < WrathParticle
  def initialize(options = {})
    options = {
      elasticity: 0,
      animation: "pixel_1x1.png",
    }.merge! options

    super options
  end

  def on_stopped
    @casts_shadow = false
    super
  end
end
end
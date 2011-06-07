# A droplet of fluid, defaulting to being white.
module Wrath
# A particle that is just a single pixel which "stains" the ground it lands on.
class Droplet < Wrath::Particle
  def initialize(options = {})
    options = {
      elasticity: 0,
      animation: Animation.new(frames: [$window.pixel]),
    }.merge! options

    super options
  end

  def on_stopped(sender)
    parent.map.set_color(x, y, color)
    destroy
  end
end
end
module Wrath
class Splinter < WrathParticle
  def initialize(options = {})
    options = {
      animation: "splinter_1x2.png",
      angle: [0, 90][rand(2)],
    }.merge! options

    super options
  end

  def on_stopped
    @casts_shadow = false
    super
  end
end
end
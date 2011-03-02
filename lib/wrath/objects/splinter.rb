class Splinter < WrathParticle
  def initialize(options = {})
    options = {
      animation: "splinter_1x2.png",
    }.merge! options

    super options
  end

  def on_stopped
    pause!
  end
end
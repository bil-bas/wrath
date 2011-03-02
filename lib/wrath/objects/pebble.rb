class Pebble < WrathParticle
  def initialize(options = {})
    options = {
      animation: "pebble_2x2.png",
    }.merge! options

    super options
  end

  def on_stopped
    pause!
  end
end
class Blood < WrathParticle
  def initialize(options = {})
    options = {
      elasticity: 0,
      animation: "blood_1x1.png",
    }.merge! options

    super options
  end

  def on_stopped
    @casts_shadow = false
    pause!
  end
end
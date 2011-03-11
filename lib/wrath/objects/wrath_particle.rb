class WrathParticle < WrathObject

  def initialize(options = {})
    options = {
      collision_type: :particle
    }.merge! options

    super(options)
  end

  def on_stopped
    @z = ground_level
    @body.reset_forces
    pause!
  end
end
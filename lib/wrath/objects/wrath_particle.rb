class WrathParticle < WrathObject

  def initialize(options = {})
    options = {
      collision_type: :particle
    }.merge! options

    super(options)
  end

  def update
    super

    if velocity == [0, 0, 0]
      @z = 0
      @body.reset_forces
      on_stopped
    end
  end
end
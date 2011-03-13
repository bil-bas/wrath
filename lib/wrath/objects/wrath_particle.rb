class WrathParticle < WrathObject

  def initialize(options = {})
    options = {
      collision_type: :particle
    }.merge! options

    super(options)
  end

  def update
    super
    update_forces
  end


  def on_stopped
    @z = ground_level
    @body.reset_forces
    pause!
  end

  def on_collision(other)
    self.x_velocity, self.y_velocity = 0, 0

    false
  end
end
class WrathParticle < WrathObject
  def update
    super

    if [x_velocity, y_velocity, z_velocity] == [0, 0, 0]
      on_stopped
    end
  end
end
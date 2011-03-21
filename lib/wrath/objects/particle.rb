module Wrath
class Particle < BaseObject

  def network_destroy?; false; end
  def network_create?; false; end
  def network_sync?; false; end

  def initialize(options = {})
    options = {
      collision_type: :particle,
      id: nil,
      thrown_by: [],
    }.merge! options

    @thrown_by = options[:thrown_by]

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
    self.x_velocity, self.y_velocity = 0, 0 unless @thrown_by.include? other

    false
  end
end
end
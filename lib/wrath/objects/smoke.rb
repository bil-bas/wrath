module Wrath
class Smoke < GameObject
  COLOR = Color.rgba(50, 50, 50, 100)
  ALPHA_DECAY_SPEED = 0.01
  RISE_SPEED = 0.003

  def initialize(options = {})
    options = {
      color: COLOR.dup,
      factor: 2,
      image: $window.pixel,
      rise_speed: RISE_SPEED,
      alpha_decay_speed: ALPHA_DECAY_SPEED,
    }.merge! options

    super options

    @rise_speed = options[:rise_speed]
    @alpha_decay_speed = options[:alpha_decay_speed]

    @alpha_float = alpha.to_f
  end

  def update
    time = parent.frame_time
    self.y -= @rise_speed * time
    @alpha_float -= @alpha_decay_speed * time
    self.alpha = @alpha_float.to_i
    if alpha <= 0
      destroy
    end
  end
end
end
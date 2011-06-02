module Wrath
class Smoke < GameObject
  COLOR = Color.rgba(50, 50, 50, 100)

  def initialize(options = {})
    options = {
      color: COLOR.dup,
      factor: 2,
      image: $window.pixel,
    }.merge! options

    super options

    @alpha_float = alpha.to_f
  end

  def update
    self.y -= 0.007 * parent.frame_time
    @alpha_float -= 0.3
    self.alpha = @alpha_float.to_i
    if alpha <= 0
      destroy
    end
  end
end
end
module Wrath
class Smoke < GameObject
  def initialize(options = {})
    options = {
      color: Color.rgba(50, 50, 50, 100),
      factor: 1.5,
      image: Image["pixel_1x1.png"],
    }.merge! options

    super options

    @alpha_float = alpha.to_f
  end

  def update
    self.y -= 0.05
    @alpha_float -= 0.3
    self.alpha = @alpha_float.to_i
    if alpha <= 0
      destroy
    end
  end
end
end
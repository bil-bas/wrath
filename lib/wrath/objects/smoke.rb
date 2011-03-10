class Smoke < GameObject
  INITIAL_ALPHA = 100

  def initialize(options = {})
    options = {
      alpha: INITIAL_ALPHA,
      factor: 1.5,
      image: Image["smoke_1x1.png"],
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
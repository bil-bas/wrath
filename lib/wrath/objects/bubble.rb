module Wrath
  class Bubble < GameObject
    COLOR = Color.rgba(255, 255, 255, 100)

    def initialize(options = {})
      options = {
        color: COLOR.dup,
        factor: 1.5,
        image: $window.pixel,
      }.merge! options

      super options

      @alpha_float = alpha.to_f
    end

    def update
      time = parent.frame_time
      self.y -= 0.02 * time
      @alpha_float -= 0.05 * time
      self.alpha = @alpha_float.to_i
      if alpha <= 0
        destroy
      end
    end
  end
end
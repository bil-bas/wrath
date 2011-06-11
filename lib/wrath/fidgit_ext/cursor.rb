module Fidgit
  class Cursor < Chingu::GameObject
    def update
      self.x, self.y = $window.mouse_x / $window.sprite_scale, $window.mouse_y / $window.sprite_scale

      super

      nil
    end
  end
end

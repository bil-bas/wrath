module Gosu
  class Window
    alias_method :old_render_to_image, :render_to_image
    def render_to_image(*args, &block)
      unretro do
        old_render_to_image(*args, &block)
      end
    end
  end
end
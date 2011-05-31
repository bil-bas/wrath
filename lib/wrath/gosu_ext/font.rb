module Gosu
  class Font
    class << self
      attr_accessor :factor_stored, :factor_rendered
    end

    self.factor_stored = 1 # How much larger is it stored as a font.
    self.factor_rendered = 1 # How much smaller it is rendered.

    alias_method :original_initialize, :initialize
    def initialize(window, name, size)
      original_initialize(window, name, (size * self.class.factor_stored).round)
    end

    alias_method :original_draw_rel, :draw_rel
    def draw_rel(text, x, y, z, rel_x, rel_y, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
      factor = self.class.factor_rendered
      original_draw_rel(text, x, y, z, rel_x, rel_y, factor_x * factor, factor_y * factor, color, mode)
    end

    alias_method :original_height, :height
    def height
      original_height / self.class.factor_stored
    end

    alias_method :original_text_width, :text_width
    def text_width(text, factor_x = 1)
      original_text_width(text, factor_x) / self.class.factor_stored
    end
  end
end
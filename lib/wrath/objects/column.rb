module Wrath
  class Column < Boulder
    def initialize(options = {})
      options = {
          animation: "column_11x18.png",
          factor_x: 1,
      }.merge! options

      super(options)
    end

    def z; super - 2; end

    def draw
      # Ensure that curved bottom still gets shown.
      super
      image.draw_rot x, y - z, y, 0, 0.5, 1
    end
  end
end
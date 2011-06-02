module Wrath
  class Metal < Tile
    SPRITE_POSITION = [5, 1]

    def edge_type; :hard_corner; end
  end
end
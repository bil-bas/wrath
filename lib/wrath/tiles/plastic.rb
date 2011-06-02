module Wrath
  class Plastic < Tile
    SPRITE_POSITION = [6, 1]

    def edge_type; :hard_corner; end
  end
end
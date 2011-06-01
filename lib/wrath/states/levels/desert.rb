module Wrath
class Level < GameState
  class Desert < Level
    DEFAULT_TILE = Sand

    CHEST_CONTENTS = [Crown, FlyingCarpet]
    GOD = Storm

    SPAWNS = {
        Sheep => 4,
        Knight => 1,
        Cultist => 4,
        Snake => 3,
    }

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Desert of Warm Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Inanimate objects.
      5.times { Chest.create(contents: CHEST_CONTENTS) }
      1.times { OgreSkull.create }

      # Static objects.
      12.times { PalmTree.create }
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)

      grid
    end
  end
end
end
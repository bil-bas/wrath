module Wrath
class Level
  class Desert < Level
    DEFAULT_TILE = Sand

    CHEST_CONTENTS = [Crown, FlyingCarpet]
    GOD = Storm
    SPAWNS = {
        Sheep => 8,
        Knight => 3,
        Cultist => 4
    }

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Desert of Warm Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      2.times { Sheep.create }
      3.times { Cultist.create }
      2.times { Knight.create }

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
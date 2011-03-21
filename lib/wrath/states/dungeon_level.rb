module Wrath
  class DungeonLevel < Play
    DEFAULT_TILE = Gravel

    CHEST_CONTENTS = [Chicken, StrengthPotion, Fire]

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Dungeon of Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      3.times { Knight.create(spawn: true) }
      2.times { BlueMeanie.create(spawn: true) }

      # Inanimate objects.
      8.times { Rock.create(spawn: true) }
      (4 + rand(3)).times { Chest.create(spawn: true, contents: CHEST_CONTENTS) }
      (1 + rand(3)).times { Mimic.create(spawn: true) }
      4.times { Fire.create(spawn: true) }
      8.times { Mushroom.create(spawn: true) }
      1.times { OgreSkull.create(spawn: true) }

      # Static objects.
      12.times { Boulder.create(spawn: true) }

      # Top "blockers", not really tangible, so don't update/sync them.
      [10, 16].each do |y|
        x = -14
        while x < $window.retro_width + 20
          Boulder.create(x: x, y: rand(4) + y)
          x += 6 + rand(6)
        end
      end
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)

      # Add water-features.
      (rand(3)).times do
        pos = [rand(num_columns - 4) + 2, rand(num_rows - 7) + 5]
        grid[pos[1]][pos[0]] = Water
        (rand(3) + 1).times do
          grid[pos[1] - 1 + rand(3)][pos[0] - 1 + rand(3)] = Water
        end
      end

      # Add lava-features.
      (rand(5) + 1).times do
        pos = [rand(num_columns - 4) + 2, rand(num_rows - 7) + 5]
        grid[pos[1]][pos[0]] = Lava
        (rand(3) + 1).times do
          grid[pos[1] - 1 + rand(3)][pos[0] - 1 + rand(3)] = Lava
        end
      end

      # Put gravel under the altar.
      ((num_rows / 2)..(num_rows / 2 + 2)).each do |y|
        ((num_columns / 2 - 2)..(num_columns / 2 + 1)).each do |x|
          grid[y][x] = Gravel
        end
      end

      grid
    end
  end
end
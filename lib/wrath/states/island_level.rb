module Wrath
  class IslandLevel < Play
    DEFAULT_TILE = Sand
    NUM_GOATS = 5
    NUM_CHICKENS = 2
    CHEST_CONTENTS = [Crown, Chicken]

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Island of Utter Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      NUM_CHICKENS.times { Chicken.create(spawn: true) }

      # Inanimate objects.
      7.times { Rock.create(spawn: true) }
      5.times { Chest.create(spawn: true, contents: CHEST_CONTENTS) }
      2.times { Fire.create(spawn: true) }
      1.times { OgreSkull.create(spawn: true) }

      # Static objects.
      12.times { PalmTree.create(spawn: true) }

      # Top "blockers", not really tangible, so don't update/sync them.
      [10, 16].each do |y|
        x = -14
        while x < $window.retro_width + 20
          Boulder.create(x: x, y: rand(4) + y, paused: true)
          x += 6 + rand(6)
        end
      end
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)

      # Add water and gravel rows.
      num_columns.times do |x|
        # Water at the bottom
        grid[num_rows - 2][x] = Water if rand(100) < 40
        grid[num_rows - 1][x] = Water

        # Gravel at the top
        (0..1).each do |y|
          grid[y][x] = Gravel
        end
      end

      # Add water-features.
      (rand(3)).times do
        pos = [rand((num_rows / 2) - 4) + 2 + (num_rows / 2), rand(num_rows - 7) + 5]
        grid[pos[1]][pos[0]] = Water
        (rand(3) + 1).times do
          grid[pos[1] - 1 + rand(3)][pos[0] - 1 + rand(3)] = Water
        end
      end

      # Put Sand under the altar.
      ((num_rows / 2)..(num_rows / 2 + 2)).each do |y|
        ((num_columns / 2 - 2)..(num_columns / 2 + 1)).each do |x|
          grid[y][x] = Sand
        end
      end

      grid
    end
  end
end
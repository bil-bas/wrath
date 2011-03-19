module Wrath
  class ForestLevel < Play
    DEFAULT_TILE = Grass
    NUM_GOATS = 5
    NUM_CHICKENS = 2
    CHEST_CONTENTS = [Crown, Chicken]

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Forest of Even More Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      1.times { @objects << Virgin.create(spawn: true) }
      NUM_GOATS.times { @objects << Goat.create(spawn: true) }
      NUM_CHICKENS.times { @objects << Chicken.create(spawn: true) }
      1.times { @objects << Bard.create(spawn: true) }

      # Inanimate objects.
      4.times { @objects << Rock.create(spawn: true) }
      3.times { @objects << Chest.create(spawn: true, contents: CHEST_CONTENTS) }
      2.times { @objects << Fire.create(spawn: true) }
      8.times { @objects << Tree.create(spawn: true) }
      5.times { @objects << Mushroom.create(spawn: true) }

      # Top "blockers", not really tangible, so don't update/sync them.
      [10, 16].each do |y|
        x = -14
        while x < $window.retro_width + 20
          Tree.create(x: x, y: rand(4) + y, paused: true)
          x += 6 + rand(6)
        end
      end
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)

      # Add forest floor.
      num_rows.times {|i| grid[0][i] = grid[1][i] = Forest }

      # Add water-features.
      (rand(5) + 1).times do
        pos = [rand(num_columns - 4) + 2, rand(num_rows - 7) + 5]
        grid[pos[1]][pos[0]] = Water
        (rand(5) + 2).times do
          grid[pos[1] - 1 + rand(3)][pos[0] - 1 + rand(3)] = [Water, Water, Sand][rand(3)]
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
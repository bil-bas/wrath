module Wrath
class Level < GameState
  class Island < Level
    DEFAULT_TILE = Sand

    CHEST_CONTENTS = [TreasureChest, Crown, FlyingCarpet]
    BARREL_CONTENTS = [Mushroom, Chicken, Pirate]
    GOD = Volcano
    SPAWNS = {
        Pirate => 3,
        Amazon => 1,
        Chicken => 1,
        Parrot => 4,
        Monkey => 2,
        Mosquito => 2,
    }

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Island of Utter Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Inanimate objects.
      7.times { Rock.create }
      3.times { Barrel.create(contents: BARREL_CONTENTS) }
      1.times { OgreSkull.create }
      3.times { X.create(contents: CHEST_CONTENTS) }

      # Static objects.
      12.times { PalmTree.create }

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
        
        # Grass at the top
        (2..4).each do |y|
          grid[y][x] = Grass
        end
         grid[5][x] = Grass if rand() < 0.75
         grid[6][x] = Grass if rand() < 0.5 and grid[5][x] == Grass
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
end
module Wrath
  class IslandLevel < Play
    DEFAULT_TILE = Sand

    CHEST_CONTENTS = [Crown, Fire]
    BARREL_CONTENTS = [Mushroom, Chicken, Pirate]
    GOD = Volcano

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Island of Utter Doom"; end

    def disaster_duration; 0; end
    def god_name; "volcano"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      2.times { Pirate.create }
      3.times { Amazon.create }
      1.times { Chicken.create }
      3.times { Parrot.create }
      2.times { Monkey.create }
      2.times { Mosquito.create }

      # Inanimate objects.
      7.times { Rock.create }
      3.times { Barrel.create(contents: BARREL_CONTENTS) }
      2.times { Fire.create }
      1.times { OgreSkull.create }
      3.times { X.create(contents: TreasureChest) }

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

    def on_disaster
      # Todo: Lava!
    end
  end
end
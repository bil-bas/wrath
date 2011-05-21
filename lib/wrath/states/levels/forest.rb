module Wrath
class Level
  class Forest < Level
    DEFAULT_TILE = Grass
    NUM_SHEEP = 5
    NUM_CHICKENS = 2
    SACK_CONTENTS = [Crown, Chicken, FlyingCarpet]
    GOD = Dryad

    SPAWNS = {
        Knight => 3,
        Virgin => 1,
        Sheep => 3,
        Chicken => 6,
        Bard => 1,
    }

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    STANDING_STONES_RADIUS = 18
    NUM_STANDING_STONES = 5

    def self.to_s; "1. Forest of Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      1.times { Virgin.create }
      NUM_SHEEP.times { Sheep.create }
      NUM_CHICKENS.times { Chicken.create }
      1.times { Bard.create }
      2.times { Knight.create }

      # Inanimate objects.
      4.times { Rock.create }
      5.times { Sack.create(contents: SACK_CONTENTS) }
      2.times { Fire.create }
      1.times { Cauldron.create }
      
      5.times { Mushroom.create }

      # Static objects.
      16.times { Tree.create(can_wake: true) } # May become ents!

      # Top "blockers", not really tangible, so don't update/sync them.
      [10, 16].each do |y|
        x = -14
        while x < $window.retro_width + 20
          Tree.create(x: x, y: rand(4) + y, paused: true)
          x += 6 + rand(6)
        end
      end


      # Standing stones.
      (-180...180).step(360 / NUM_STANDING_STONES) do |angle|
        angle = angle.degrees_to_radians
        Boulder.create(x: altar.x + Math::sin(angle) * STANDING_STONES_RADIUS,
                       y: altar.y + Math::cos(angle) * STANDING_STONES_RADIUS, factor_x: 0.7)
      end
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)

      # Add forest floor.
      num_rows.times {|i| grid[0][i] = grid[1][i] = ForestFloor }

      # Add water-features.
      (rand(5) + 1).times do
        pos = [rand(num_columns - 4) + 2, rand(num_rows - 7) + 5]
        grid[pos[1]][pos[0]] = Water
        (rand(5) + 2).times do
          grid[pos[1] - 1 + rand(3)][pos[0] - 1 + rand(3)] = [Water, Water, Earth].sample
        end
      end

      # Put Earth under the altar and standing stones.
      ((num_rows / 2 - 1)..(num_rows / 2 + 3)).each do |y|
        ((num_columns / 2 - 3)..(num_columns / 2 + 2)).each do |x|
          grid[y][x] = Earth
        end
      end

      grid
    end
  end
end
end
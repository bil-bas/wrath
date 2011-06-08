module Wrath
class Level < GameState
  class Forest < Level
    DEFAULT_TILE = Grass
    GOD = Dryad
    STANDING_STONES_RADIUS = 18
    NUM_STANDING_STONES = 5
    
    def self.unlocked?; true; end # First level, so is unlocked by default.

    def create_objects
      super

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
      num_columns.times do |i|
        grid[0][i] = grid[1][i] = ForestFloor
      end

      # Add water-features.
      (rand(2) + 1).times do
        pos = [rand(num_columns - 4) + 2, rand(num_rows - 7) + 5]
        grid[pos[1]][pos[0]] = Water
        Tile::ADJACENT_OFFSETS.sample(rand(4) + 3).each do |offset_x, offset_y|
          grid[pos[1] + offset_x][pos[0] + offset_y] = [Water, Water, Earth].sample
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
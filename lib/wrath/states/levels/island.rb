module Wrath
class Level < GameState
  class Island < Level
    DEFAULT_TILE = Sand
    GOD = Volcano

    def create_objects
      super

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
        (0..0).each do |y|
          grid[y][x] = Gravel
        end
        
        # Grass at the top
        (1..4).each do |y|
          grid[y][x] = Grass
        end
        grid[5][x] = Grass if rand() < 0.75
        grid[6][x] = Grass if rand() < 0.5 and grid[5][x] == Grass
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
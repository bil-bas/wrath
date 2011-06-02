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


    def self.to_s; "Desert of Dehydrated Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Inanimate objects.
      5.times { Chest.create(contents: CHEST_CONTENTS) }
      1.times { OgreSkull.create }

      # Static objects.

      map.tiles.flatten.select {|t| t.is_a? Sand }.each do |tile|
        if tile.adjacent_tiles(directions: :orthogonal).any? {|t| t.is_a? Water }
          PalmTree.create(x: tile.x, y: tile.y, z: 0) if rand() < 0.6
        end
      end
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)

      # Add rocky bits.
      (rand(2) + 1).times do
        pos = [rand(num_columns - 4) + 2, rand(num_rows - 4) + 2]
        grid[pos[1]][pos[0]] = Gravel
        Tile::ADJACENT_OFFSETS.sample(rand(3) + 1).each do |offset_x, offset_y|
          grid[pos[1] + offset_x][pos[0] + offset_y] = Gravel
        end
      end

      # Add water-features.
      (rand(2) + 1).times do
        pos = [rand(num_columns - 4) + 2, rand(num_rows - 7) + 5]
        grid[pos[1]][pos[0]] = Water
        Tile::ADJACENT_OFFSETS.sample(rand(5) + 4).each do |offset_x, offset_y|
          grid[pos[1] + offset_x][pos[0] + offset_y] = Water
        end
      end

      # Put sand under the altar, to clean away water.
      ((num_rows / 2 - 1)..(num_rows / 2 + 3)).each do |y|
        ((num_columns / 2 - 3)..(num_columns / 2 + 2)).each do |x|
          grid[y][x] = Sand
        end
      end

      grid
    end
  end
end
end
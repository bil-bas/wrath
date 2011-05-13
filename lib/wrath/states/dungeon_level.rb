module Wrath
  class DungeonLevel < Play
    DEFAULT_TILE = Gravel
    GOD = Earthquake

    CHEST_CONTENTS = [Chicken, StrengthPotion, Fire, FlyingCarpet ]

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Dungeon of Doom"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      3.times { Knight.create }
      2.times { BlueMeanie.create }

      # Inanimate objects.
      8.times { Rock.create }
      (4 + rand(3)).times { Chest.create(contents: CHEST_CONTENTS) }
      (1 + rand(3)).times { Mimic.create }
      4.times { Fire.create }
      8.times { Mushroom.create }
      1.times { OgreSkull.create }

      # Static objects.
      12.times { Boulder.create }

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

    def draw
      if started?
        # Draw overlay to make it look dark.
        $window.pixel.draw(0, 0, ZOrder::FOREGROUND, $window.width, $window.height, DARKNESS_COLOR)

        if @god.quake_offset == 0
          super
        else
          $window.translate(0, Math::sin(milliseconds / 50.0) * @god.quake_offset) do
            super
          end
        end
      else
        super
      end
    end
  end
end
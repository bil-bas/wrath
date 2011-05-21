module Wrath
class Level
  class Ship < Level
    DEFAULT_TILE = Planking

    CHEST_CONTENTS = [Crown, Fire, Rope]
    BARREL_CONTENTS = [Chicken, Grog]
    GOD = Storm
    SPAWNS = {
        PirateCaptain => 1,
        Pirate => 6,
        Parrot => 3,
        Monkey => 2,
    }

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]
    MAST_SPAWNS = [[-50, 0], [+50, 0]]

    def self.to_s; "4. Ship of Doomed Fools"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      1.times { PirateCaptain.create }
      5.times { Pirate.create }
      2.times { Parrot.create }
      1.times { Monkey.create }

      # Inanimate objects.
      7.times { Barrel.create(contents: BARREL_CONTENTS) }
      2.times { TreasureChest.create }
      2.times { Chest.create(contents: CHEST_CONTENTS) }
      3.times { Grog.create }
      2.times { Rope.create }

      # Static objects.
      MAST_SPAWNS.each do |pos|
        Mast.create(x: altar.x + pos[0], y: Margin::TOP + (($window.retro_height - Margin::TOP) / 2) + pos[1])
      end

      (0...$window.retro_width).step(8) do |x|
        Bulwalk.create(x: x + 4, y: 16) unless x.between?($window.retro_width / 2 - 8, $window.retro_width / 2)
        Bulwalk.create(x: x + 4, y: $window.retro_height - 1)
      end
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)

      num_columns.times do |x|
        # Water at the top.
        grid[0][x] = grid[1][x] = SeaWater
      end

      grid
    end

    def update
      super

      if started?
        2.times { WaterDroplet.create(parent: self, position: [rand($window.retro_width), rand($window.retro_height), 1],
                                      velocity: [-0.5 + rand(0.99), 0, 0.2 + rand(0.3)], casts_shadow: false) }
      end
    end

    def create_altar
      Altar.create(x: $window.retro_width / 2, y: Tile::HEIGHT * 2.5)
    end
  end
end
end
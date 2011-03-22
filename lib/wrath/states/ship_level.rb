module Wrath
  class ShipLevel < Play
    DEFAULT_TILE = Planking

    CHEST_CONTENTS = [Crown, Fire]
    BARREL_CONTENTS = [Mushroom, Chicken, Pirate]

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]
    MAST_SPAWNS = [[-50, 0], [+50, 0]]

    def self.to_s; "Ship of Doomed Fools"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      5.times { Pirate.create }
      2.times { Parrot.create }
      1.times { Monkey.create }

      # Inanimate objects.
      5.times { Barrel.create(contents: BARREL_CONTENTS) }
      2.times { TreasureChest.create }
      2.times { Chest.create(contents: CHEST_CONTENTS) }

      # Static objects.
      MAST_SPAWNS.each do |pos|
        Mast.create(x: altar.x + pos[0], y: altar.y + pos[1])
      end
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)
      grid
    end
  end
end
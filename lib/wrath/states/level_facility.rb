module Wrath
  class LevelFacility < Level
    DEFAULT_TILE = Plastic

    GOD = Ai
    SPAWNS = {
        CompanionCube => 5,
        TestSubject => 1,
        Turret => 7,
    }

    # This is relative to the altar.
    PLAYER_SPAWNS = [[-12, 0], [12, 0]]

    def self.to_s; "Test Facility: D.O.O.M"; end

    def create_objects
      super(PLAYER_SPAWNS)

      # Mobs.
      4.times { CompanionCube.create }
      1.times { TestSubject.create }
      5.times { Turret.create }

      # Static objects.
      18.times { Block.create(stack: [1, 1, 1, 1, 2, 2, 3].sample) }

      (0...$window.retro_width).step(9) do |x|
        Block.create(x: x + 4, y: 20, stack: 2)
      end
    end

    def random_tiles
      num_columns, num_rows, grid = super(DEFAULT_TILE)

      grid
    end
  end
end
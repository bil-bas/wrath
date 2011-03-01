class Bard < Mob
  trait :timer

  def favor; 40; end # Extra because even the gods dislike poor musicianship.

  def initialize(options = {})
    options = {
      vertical_jump: 0.2,
      horizontal_jump: 1.2,
      elasticity: 0.4,
      jump_delay: 1500,
      encumbrance: 0.4,
      animation: "bard_8x8.png",
    }.merge! options

    super options

    after(1) { play }
  end

  def play
    if [x_velocity, y_velocity, z_velocity] == [0, 0, 0]
      # local=false, id = -1 is hack to stop updates.
      Note.create(local: false, id: -1, x: x + (factor_x * 4) - 1 + rand(3), y: y, z: z + 3)
    end

    after(400 + rand(300)) { play }
  end
end
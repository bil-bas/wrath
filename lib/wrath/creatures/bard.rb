module Wrath
class Bard < Mob
  trait :timer

  public
  def initialize(options = {})
    options = {
      favor: 35,
      health: 30,
      vertical_jump: 0.2,
      horizontal_jump: 1.2,
      elasticity: 0.4,
      jump_delay: 1500,
      encumbrance: 0.4,
      z_offset: -2,
      animation: "bard_8x8.png",
    }.merge! options

    super options

    after(2) { play }
  end

  protected
  def play
    if [x_velocity, y_velocity, z_velocity] == [0, 0, 0]
      Note.create(parent: parent, x: x + (factor_x * 4) - 1 + rand(3), y: y, z: z + 3)
    end

    after(400 + rand(3) * 200) { play }
  end
end
end
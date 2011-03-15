module Wrath

class Chicken < Mob
  PERCENTAGE_LAYING_AN_EGG = 33

  def initialize(options = {})
    options = {
      favor: 10,
      health: 10,
      vertical_jump: 0.1,
      horizontal_jump: 0.2,
      jump_delay: 250,
      encumbrance: 0.1,
      z_offset: -1,
      animation: "chicken_6x6.png",
    }.merge! options

    super(options)
  end

  def dropped(player, x_velocity, y_velocity, z_velocity)
    super(player, x_velocity, y_velocity, z_velocity)

    unless parent.client?
      player.pick_up(Egg.create(parent: parent)) if rand(100) < PERCENTAGE_LAYING_AN_EGG
    end
  end
end
end
# encoding: utf-8

class Chicken < Mob
  PERCENTAGE_LAYING_AN_EGG = 33

  def favor; 10; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.1,
      horizontal_jump: 0.2,
      jump_delay: 250,
      encumbrance: 0.2,
      z_offset: -1,
      animation: "chicken_6x6.png",
    }.merge! options

    super(options)
  end

  def dropped(player, x_velocity, y_velocity, z_velocity)
    super(player, x_velocity, y_velocity, z_velocity)
    player.pick_up(Egg.create) if rand(100) < PERCENTAGE_LAYING_AN_EGG
  end
end
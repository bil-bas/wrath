# encoding: utf-8

class Chicken < Mob
  def favor; 10; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.1,
      horizontal_jump: 0.2,
      jump_delay: 250,
      encumbrance: 0.2,
      animation: "chicken_6x6.png",
    }.merge! options

    super(options)
  end

  def drop(player, x_velocity, y_velocity, z_velocity)
    super(player, x_velocity, y_velocity, z_velocity)
    player.pick_up Egg.create
  end
end
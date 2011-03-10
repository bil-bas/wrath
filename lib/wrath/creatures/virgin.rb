# encoding: utf-8

class Virgin < Mob
  def favor; 40; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.05,
      horizontal_jump: 0.5,
      jump_delay: 500,
      encumbrance: 0.4,
      animation: "virgin_8x8.png",
    }.merge! options

    super options
  end

  def ghost_disappeared
    horse = Horse.create(spawn: true, parent: parent)
    parent.objects.push horse
    parent.objects.push Paladin.create(parent: parent, x: horse.x, y: horse.y - 6, y_velocity: 0.5, z_velocity: 0.5)
  end
end
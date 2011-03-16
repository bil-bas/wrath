module Wrath

class Virgin < Mob
  def initialize(options = {})
    options = {
      favor: 40,
      health: 30,
      vertical_jump: 0.05,
      horizontal_jump: 0.5,
      jump_delay: 500,
      encumbrance: 0.4,
      z_offset: -2,
      animation: "virgin_8x8.png",
    }.merge! options

    super options
  end

  def ghost_disappeared
    unless parent.client?
      horse = Horse.create(spawn: true, parent: parent)
      parent.objects.push horse
      paladin = Paladin.create(parent: parent, x: horse.x, y: horse.y - 6, y_velocity: 0.5, z_velocity: 0.5)
      paladin.mount(horse)
    end

    super
  end
end
end
module Wrath

class Virgin < Humanoid
  def initialize(options = {})
    options = {
      favor: 15,
      health: 30,
      encumbrance: 0.4,
      z_offset: -2,
      animation: "virgin_8x8.png",
    }.merge! options

    super options

    @creator = parent # Save the creator, since #ghost_disappeared is called after we are destroyed.
  end

  def ghost_disappeared
    unless @creator.client?
      horse = Horse.create(parent: @creator)
      @creator.objects.push horse
      paladin = Paladin.create(parent: @creator, x: horse.x, y: horse.y - 6, y_velocity: 0.5, z_velocity: 0.5)
      paladin.mount(horse)
    end

    super
  end
end
end
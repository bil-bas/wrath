module Wrath

class Chicken < Mob
  PERCENTAGE_LAYING_AN_EGG = 33

  public
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

  public
  def on_being_dropped(actor)
    super(actor)
    if actor.is_a? Creature and not parent.client?
      actor.pick_up(Egg.create(parent: parent)) if rand(100) < PERCENTAGE_LAYING_AN_EGG
    end
  end
end
end
class Mushroom < Carriable
  POISON_DURATION = 4000

  def initialize(options = {})
    options = {
      factor: 0.7,
      encumbrance: 0.1,
      elasticity: 0,
      z_offset: 0,
      animation: "mushroom_6x5.png",
    }.merge! options

    super options
  end

  # Forces the player to drop whatever he is carrying and get covered with a broken egg.
  def hit(player)
    player.poison(POISON_DURATION)
    destroy
  end
end
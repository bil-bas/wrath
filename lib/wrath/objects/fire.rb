require_relative 'static_object'

class Fire < StaticObject
  trait :timer

  include Carriable

  ANIMATION_DELAY = 300
  WEAR_HURT_DELAY = 300
  WEAR_BURN_DAMAGE = 1

  trait :timer

  # To change this template use File | Settings | File Templates.

  def initialize(options = {})
    options = {
      encumbrance: -0.5,
      elasticity: 0.2,
      animation: "fire_8x8.png",
    }.merge! options

    super options

    @frames.delay = ANIMATION_DELAY
  end

  def update
    super
    self.image = @frames.next
  end

  def pick_up(player, offset)
    every(WEAR_HURT_DELAY, name: :burn) { player.health -= WEAR_BURN_DAMAGE }

    super(player, offset)
  end

  def drop(*args)
    stop_timer(:burn)

    super(*args)
  end
end
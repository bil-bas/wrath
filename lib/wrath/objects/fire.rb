require_relative 'static_object'

class Fire < StaticObject
  trait :timer

  include Carriable

  SPRITE_POSITIONS = [[0, 3], [1, 3]]
  ANIMATION_DELAY = 300
  WEAR_HURT_DELAY = 300
  WEAR_BURN_DAMAGE = 1

  trait :timer

  # To change this template use File | Settings | File Templates.

  def initialize(options = {})
    options = {
      encumbrance: -0.5,
      elasticity: 0.2,
      shadow_width: 0,
    }.merge! options

    @frames = SPRITE_POSITIONS.map {|p| @@sprites[*p] }
    @frame_index = 0

    super SPRITE_POSITIONS[0], options

    every(ANIMATION_DELAY) do
      @frame_index = (@frame_index + 1) % @frames.size
      self.image = @frames[@frame_index]
    end
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
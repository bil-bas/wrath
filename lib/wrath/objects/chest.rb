require_relative 'static_object'
require_relative '../carriable'

class Chest < StaticObject
  include Carriable

  def open?; @open; end
  def closed?; not @open; end

  OPEN_SPRITE_POS = [1, 5]
  CLOSED_SPRITE_POS = [0, 5]

  def initialize(options = {})
    options = {
      encumbrance: 0.6,
      elasticity: 0.4,
    }.merge! options

    @open = options[:open]
    @contains = Array(options[:contains])

    @open_sprite = @@sprites[*OPEN_SPRITE_POS]

    super CLOSED_SPRITE_POS, options
  end

  def open
    @open = true

    self.image = @open_sprite
    object = @contains[rand(@contains.size)].create(x: x, y: y, z: 6, z_velocity: 1, y_velocity: 0.1)

    $window.current_game_state.mobs.push object

    @contains = nil
  end
end
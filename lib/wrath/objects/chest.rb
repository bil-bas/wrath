require_relative 'static_object'
require_relative '../carriable'

class Chest < StaticObject
  include Carriable

  def open?; @open; end
  def closed?; not @open; end

  CLOSED_SPRITE_FRAME = 0
  OPEN_SPRITE_FRAME = 1

  def initialize(options = {})
    options = {
      encumbrance: 0.6,
      elasticity: 0.4,
      animation: "chest_8x8.png",
      open: false,
    }.merge! options

    @open = options[:open]
    @contains = Array(options[:contains])

    super options
  end

  def open
    @open = true

    self.image = @frames[OPEN_SPRITE_FRAME]
    object = @contains[rand(@contains.size)].create(x: x, y: y, z: 6, z_velocity: 1, y_velocity: 0.1)

    $window.current_game_state.mobs.push object

    @contains = nil
  end
end
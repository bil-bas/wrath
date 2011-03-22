module Wrath
class AnimatedTile < Tile
  ANIMATION_PERIOD = 500

  def sprite_position; animation_positions[0]; end
  def animation_positions; self.class.const_get(:ANIMATION_POSITIONS); end

  def initialize(options = {})
    super(options)

    @animation = Animation.new(delay: 0, frames: animation_positions.map {|pos| @@sprites[*pos] })
  end

  # The map will animate all tiles at once.
  def animate
    self.image = @animation.next
  end
end
end
class AnimatedTile < Tile
  def sprite_position; animation_positions[0]; end
  def animation_positions; self.class.const_get(:ANIMATION_POSITIONS); end

  def initialize(options = {})
    @animation = Animation.new(delay: 500, frames: animation_positions.map {|pos| @@sprites[*pos] })

    super(options)
  end

  def update
    self.image = @animation.next
    super
  end
end
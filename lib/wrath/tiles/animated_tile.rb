class AnimatedTile < Tile
  def sprite_position; animation_positions[0]; end
  def animation_positions; self.class.const_get(:ANIMATION_POSITIONS); end

  def initialize(options = {})
    @@junk_anims ||= Animation.new(file: "tiles_8x8.png", delay: 500)

    @animation = @@junk_anims[0..1]
    @animation.frames = animation_positions.map {|pos| @@sprites[*pos]}

    super(options)
  end

  def update
    self.image = @animation.next
    super
  end
end
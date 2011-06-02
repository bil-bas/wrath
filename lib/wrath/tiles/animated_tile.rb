module Wrath
class AnimatedTile < Tile
  ANIMATION_PERIOD = 500

  def sprite_position; animation_positions[0]; end
  def animation_positions; self.class.const_get(:ANIMATION_POSITIONS); end

  def initialize(map, grid_x, grid_y, options = {})
    super(map, grid_x, grid_y, options)

    @animation = Animation.new(delay: 0, frames: animation_positions.map {|pos| @@sprites[*pos] })
  end

  # The map will animate all tiles at once.
  def animate
    self.image = @animation.next
  end

  public
  def render_edges
    return if self.is_a? parent.class::DEFAULT_TILE or edge_type == :hard_corner

    adjacent = adjacent_sameness

    @animation.frames.size.times do |i|
      @animation.frames[i] = edged_image(@animation[i], adjacent)
    end
  end
end
end
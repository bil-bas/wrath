require_relative 'static_object'

class Fire < StaticObject
  SPRITE_POSITIONS = [[0, 3], [1, 3]]
  ANIMATION_DELAY = 300

  trait :timer

  # To change this template use File | Settings | File Templates.

  def initialize(options = {})
    options = {
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
end
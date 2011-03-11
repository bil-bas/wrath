class Water < AnimatedTile
  ANIMATION_POSITIONS = [[0, 3], [1, 3]]
  IMAGE_POSITION_FILLED = [2, 3]

  EMPTY_LEVEL = -3
  FULL_LEVEL = 0

  def filled?; @filled; end

  def initialize(options = {})
    options = {
        ground_level: EMPTY_LEVEL,
        speed: 0.25,
    }.merge! options

    super options

    @filled_image = @@sprites[*IMAGE_POSITION_FILLED]
    @filled = false
  end

  def draw
    super
    @filled_image.draw_rot(x, y, zorder, 0, 0.5, 0.5, factor_x, factor_y) if filled?
  end

  def add(object)
    case object
      when Fire, Particle
        object.destroy
        return
      when Rock
        unless filled?
          object.destroy
          @filled = true
          @ground_level = FULL_LEVEL
          @speed = 1
          return
        end
    end

    super(object)
  end
end
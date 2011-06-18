module Wrath
class Water < AnimatedTile
  ANIMATION_POSITIONS = [[0, 3], [1, 3]]
  IMAGE_POSITION_FILLED = [2, 3]

  EMPTY_LEVEL = -3
  FULL_LEVEL = 0
  FULL_SPEED = 1
  EMPTY_SPEED  = 0.25

  def filled?; @filled; end
  def edge_type; :hard_curve; end
  
  def filled=(value)
    @filled = value
    @ground_level = @filled ? FULL_LEVEL : EMPTY_LEVEL
    @speed = @filled ? FULL_SPEED : EMPTY_SPEED
  end

  def initialize(map, grid_x, grid_y, options = {})
    options = {
        ground_level: EMPTY_LEVEL,
        speed: EMPTY_SPEED,
    }.merge! options

    super(map, grid_x, grid_y, options)

    @splasher = Emitter.new(WaterDroplet, parent, h_speed: 0.05..0.1,
        z_velocity: 0.1..0.2)

    @filled_image = @@sprites[*IMAGE_POSITION_FILLED]
    @filled = false
  end

  def draw
    super
    @filled_image.draw_rot(x, y, zorder, 0, 0.5, 0.5, factor_x, factor_y) if filled?
  end

  def touched_by(object)
    case object
      when Fire, Wrath::Particle
        object.destroy
        return

      when Rock
        unless filled?
          splash(object)
          object.destroy
          self.filled = true
          return
        end

      when DynamicObject
        object.remove_status(:burning) if object.burning? and not object.parent.client?

      else
        if not filled? and (object.z + object.height) > 0 and rand(100) < 15
          splash(object)
        end
    end

    super(object)
  end

  def splash(object)
    num_droplets = (object.x_velocity ** 2 + object.y_velocity ** 2 + object.z_velocity ** 2).to_i
    @splasher.emit([object.x, object.y, 0.1], number: num_droplets, thrown_by: object) if num_droplets > 0
  end
end
end
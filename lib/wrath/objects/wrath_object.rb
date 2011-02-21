# encoding: utf-8

class WrathObject < GameObject
  VERTICAL_ACCELERATION = -0.1

  attr_accessor :z

  def carriable?; false; end
  def affected_by_gravity?; true; end

  def initialize(image_row, options = {})
    options = {
      rotation_center: :bottom_center,
      factor_x: [1, -1][rand(2)],
      spawn: false,
      z: 0,
    }.merge! options

    @z = options[:z]
    @x_velocity = 0
    @y_velocity = 0
    @z_velocity = 0

    super(options)

    spawn if options[:spawn]
  end


  def spawn
    self.x, self.y = spawn_position
  end

  def draw
    # Draw a shadow
    $window.pixel.draw(x - width / 2, y - 1, y, width, 1, Color.rgba(0, 0, 0, 50))

    draw_relative(0, -z, y)
  end

  def update
    if affected_by_gravity? and (@z_velocity != 0 or @z > 0)
      @z_velocity += VERTICAL_ACCELERATION
      @z += @z_velocity

      if @z <= 0
        @z = 0
        @z_velocity = - @z_velocity * 0.6

        if @z_velocity < 0.2
          @z_velocity = 0
          @x_velocity = 0
          @y_velocity = 0
        end
      end

      self.factor_x = 1 if @x_velocity > 0
      self.factor_x = -1 if @x_velocity < 0

      self.x += @x_velocity
      self.x = [[x, width / 2].max, $window.retro_width - width / 2].min
      self.y += @y_velocity
      self.y = [[y, height].max, $window.retro_height].min
    end

    super
  end

  def spawn_position
    [rand(($window.width / $window.sprite_scale) - width) + width / 2,
     rand(($window.height / $window.sprite_scale) - height) + height / 2]
  end
end
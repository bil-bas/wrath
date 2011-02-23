# encoding: utf-8

class WrathObject < GameObject
  VERTICAL_ACCELERATION = -0.1

  attr_accessor :z, :x_velocity, :y_velocity, :z_velocity

  def casts_shadow?; @casts_shadow; end
  def carriable?; false; end
  def affected_by_gravity?; true; end

  def initialize(options = {})
    options = {
      rotation_center: :bottom_center,
      factor_x: [1, -1][rand(2)],
      spawn: false,
      elasticity: 0.6,
      x_velocity: 0,
      y_velocity: 0,
      z_velocity: 0,
      z: 0,
      casts_shadow: true,
    }.merge! options

    @frames = Animation.new(file: options[:animation])
    @frames.delay = 0 # Don't animate by default.

    options[:image] = @frames[0]

    @z = options[:z]
    @x_velocity = options[:x_velocity]
    @y_velocity = options[:y_velocity]
    @z_velocity = options[:z_velocity]
    @elasticity = options[:elasticity]
    @casts_shadow = options[:casts_shadow]

    super(options)

    spawn if options[:spawn]
  end


  def spawn
    self.x, self.y = spawn_position
  end

  def draw
    # Draw a shadow
    if casts_shadow? and not @carrier  # Don't draw a shadow if carried, since the carrier will deal with it.
      shadow_width = width
      shadow_width = [shadow_width, @carrying.width].max if @carrying
      $window.pixel.draw(x - (shadow_width / 2.0), y - 1, y, shadow_width, 1, Color.rgba(0, 0, 0, 50))
    end

    draw_relative(0, -z, y)
  end

  def update
    if affected_by_gravity? and (@z_velocity != 0 or @z > 0)
      @z_velocity += VERTICAL_ACCELERATION
      @z += @z_velocity

      if @z <= 0
        @z = 0
        @z_velocity = - @z_velocity * @elasticity

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

  def sacrificed(player, altar)
    destroy
  end
end
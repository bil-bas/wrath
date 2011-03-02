# encoding: utf-8

class WrathObject < GameObject
  GRAVITY = -0.1

  TOP_MARGIN = 16 # Unenterable region at the top of the screen.

  @@next_object_id = 0

  attr_accessor :z, :x_velocity, :y_velocity, :z_velocity, :id

  def needs_sync?; @needs_sync; end

  def casts_shadow?; @casts_shadow; end
  def carriable?; false; end
  def affected_by_gravity?; true; end
  def remote?; not @local; end
  def local?; @local; end

  def initialize(options = {})
    options = {
      rotation_center: :bottom_center,
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

    if options[:id]
      @id = options[:id]
      @local = options[:local] || false
    else
      @id = @@next_object_id
      @@next_object_id += 1
      @local = options.has_key?(:local) ? options[:local] : true
      # Todo: This is horrid!
      if @parent.network.is_a? Server
        @parent.network.broadcast_msg(Message::Create.new(object_class: self.class, options: recreate_options))
      end
    end

    @needs_sync = false
    @previous_position = [x, y, z]
    @previous_velocity = [x_velocity, y_velocity, z_velocity]
  end

  def sync_data
    @needs_sync = false

    { id: id, time: milliseconds, position: [x, y, z], velocity: [x_velocity, y_velocity, z_velocity] }
  end

  def sync(data)
    self.x, self.y, self.z = data.position

    self.x_velocity, self.y_velocity, self.z_velocity = data.velocity
  end

  def recreate_options
    {
      id: id,
      x: x, y: y, z: z,
      x_velocity: x_velocity, y_velocity: y_velocity, z_velocity: z_velocity,
      factor_x: factor_x,
      paused: paused?,
    }
  end

  def spawn
    self.x, self.y = spawn_position
  end

  def draw
    # Draw a shadow
    if casts_shadow?
      color = Color.rgba(0, 0, 0, alpha)

      top_left = [x + (z * 0.5), y - (height + z) * 0.5, color]
      top_right = [x + width + (z * 0.5), y - (height + z) * 0.5, color]
      bottom_left = [x - (width - z) * 0.5, y - z * 0.5, color]
      bottom_right = [x + (width + z) * 0.5, y - z * 0.5, color]

      if factor_x > 0
        image.draw_as_quad(*top_left, *top_right, *bottom_left, *bottom_right, ZOrder::SHADOWS)
      else
        image.draw_as_quad(*top_right, *top_left, *bottom_right, *bottom_left, ZOrder::SHADOWS)
      end
    end

    draw_relative(0, -z, y)
  end

  def update
    if affected_by_gravity? and (@z_velocity != 0 or @z > 0)
      @z_velocity += GRAVITY
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
    end

    if (factor_x > 0 and x_velocity < 0) or
        (factor_x < 0 and x_velocity > 0)
      self.factor_x *= -1
    end

    self.x += @x_velocity
    self.x = [[x, width / 2].max, $window.retro_width - width / 2].min
    self.y += @y_velocity
    self.y = [[y, TOP_MARGIN].max, $window.retro_height].min

    super

    # If we have moved then we need to update for the client.
    position = [x, y, z]
    velocity = [x_velocity, y_velocity, z_velocity]

    # If we haven't sent an update that needs sending, then doesn't matter if we are stationary.
    # We still need to send it when we get the chance.
    unless needs_sync?
      @needs_sync = position != @previous_position or velocity != @previous_velocity
    end

    @previous_position = position
    @previous_velocity = velocity
  end

  def spawn_position
    loop do
      pos = [rand(($window.width / $window.sprite_scale) - width) + width / 2,
             rand(($window.height / $window.sprite_scale) - height) + height / 2]

      return pos if distance(*pos, $window.retro_width / 2, $window.retro_width / 2) > 40
    end
  end

  def sacrificed(player, altar)
    @sacrificial_explosion.blast(altar.x, altar.y, altar.z + altar.height) if @sacrificial_explosion
    destroy
  end

  def destroy
    super

    if @parent.network and local?
      @parent.network.broadcast_msg(Message::Destroy.new(id: id))
    end
  end
end
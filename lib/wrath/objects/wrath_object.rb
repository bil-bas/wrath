# encoding: utf-8

require 'forwardable'

class WrathObject < GameObject
  extend Forwardable

  GRAVITY = -5 / 1000.0 # Acceleration per second.

  @@next_object_id = 0

  attr_reader :frames, :elasticity, :favor
  attr_accessor :z, :x_velocity, :y_velocity, :z_velocity, :id

  def needs_sync?; @needs_sync; end

  def controlled_by_player?; false; end
  def casts_shadow?; @casts_shadow; end
  def can_pick_up?; false; end
  def affected_by_gravity?; true; end
  def remote?; not @local; end
  def local?; @local; end
  def controlled_by_player?; false; end

  def_delegators :@body_position, :x, :y, :x=, :y=

  def_delegators :@body, :reset_forces

  def position; [x, y, @z]; end
  def position=(coordinates); @body_position.x, @body_position.y, @z = coordinates; end
  def velocity; [@x_velocity, @y_velocity, @z_velocity]; end
  def velocity=(vector); @x_velocity, @y_velocity, @z_velocity = vector; end

  def initialize(options = {})
    options = {
      rotation_center: :bottom_center,
      spawn: false,
      elasticity: 0.6,
      x_velocity: 0,
      y_velocity: 0,
      z_velocity: 0,
      x: 0,
      y: 0,
      z: 0,
      favor: 0,
      mass: 1,
      casts_shadow: true,
      collision_type: :object,
      shape: :rectangle,
    }.merge! options

    @favor = options[:favor]

    @frames = Animation.new(file: options[:animation])
    @frames.delay = 0 # Don't animate by default.

    options[:image] = @frames[0]

    options[:animation] =~ /(\d+)x(\d+)/
    width, height = $1.to_i, $2.to_i
    init_physics(options[:x], options[:y], width, height, options[:collision_type], options[:shape], options[:mass])

    @z = options[:z]
    @elasticity = options[:elasticity]
    @casts_shadow = options[:casts_shadow]

    super(options)

    self.velocity = options[:velocity] || [options[:x_velocity], options[:y_velocity], options[:z_velocity]]
    self.position = options[:position] || [options[:x], options[:y], options[:z]]

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
        @parent.network.broadcast_msg(Message::Create.new(self.class, recreate_options))
      end
    end

    @tile = nil

    @needs_sync = false
    @previous_position = position
    @previous_velocity = velocity

    @parent.space.add_body @body unless @body.mass == Float::INFINITY
    @parent.space.add_shape @shape
  end

  def init_physics(x, y, width, height, collision_type, shape, mass)
    @body = CP::Body.new(mass, Float::INFINITY)
    @body.p = CP::Vec2.new(x, y)
    @body_position = @body.p

    @shape = case shape
      when :rectangle
        depth = width / 4.0
        vertices = [CP::Vec2.new(-width / 2, -depth), CP::Vec2.new(-width / 2, depth),
                    CP::Vec2.new(width / 2, depth), CP::Vec2.new(width / 2, -depth)]
        CP::Shape::Poly.new(@body, vertices, CP::Vec2.new(0,0))
      when :circle
        CP::Shape::Circle.new(@body, width / 2, CP::Vec2.new(0,0))
      else
        raise "Bad shape"
    end

    @shape.e = 0
    @shape.u = 0.5
    @shape.collision_type = collision_type
    @shape.owner = self
  end

  def sync(position, velocity)
    self.position = position
    self.velocity = velocity
  end

  def recreate_options
    {
      id: id,
      position: position,
      velocity: velocity,
      factor_x: factor_x,
      paused: paused?,
    }
  end

  def spawn
    self.position = spawn_position
  end

  def draw
    if z < 0
      # Clip bottom of sprite, but allow shadow to still be seem (sticks out horizontally)
      $window.clip_to(x - width * 1.5, y - height, width * 3, height) do
        draw_self
      end
    else
      draw_self
    end
  end

  def draw_self
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

    @image.draw_rot(x, y - z, y, 0, 0.5, 1, @factor_x, @factor_y, @color, @mode)
  end

  def ground_level
    @tile ? @tile.ground_level : 0
  end

  def update
    # Check which tile we start on.
    @old_tile = @tile
    @tile = parent.tile_at_coordinate(x, y)

    @tile.touched_by(self) unless @tile.nil? or z > 0

    @z = ground_level if z <= ground_level

    # Deal with vertical physics manually.
    if affected_by_gravity? and (@z_velocity != 0 or @z > ground_level)
      @z_velocity += GRAVITY * frame_time
      @z += @z_velocity

      if @z <= ground_level
        @z = ground_level
        @z_velocity = - @z_velocity * @elasticity if @z_velocity < 0

        if @z_velocity < 0.2
          self.velocity = [0, 0, 0]
          on_stopped
        else
          on_bounced
        end
      end
    end

    # Set facing based on direction of movement.
    if (factor_x > 0 and x_velocity < 0) or
        (factor_x < 0 and x_velocity > 0)
      self.factor_x *= -1
    end

    super
  end

  def frame_time
    parent.frame_time
  end

  def update_forces
    @body.reset_forces

    return if paused?
    # Apply a pushing force if the object is moving.
    if [@x_velocity, @y_velocity] != [0, 0]
      modifier = 2000
      modifier *= @tile.speed if z <= 0 and @tile

      @body.apply_force(CP::Vec2.new(@x_velocity * modifier, @y_velocity * modifier),
                        CP::Vec2.new(0, 0))
    end
  end

  def set_body_velocity(angle, force)
    @x_velocity = offset_x(angle, 1) * force
    @y_velocity = offset_y(angle, 1) * force
 end

  def spawn_position
    loop do
      pos = [rand($window.retro_width - width * 2) + width,
             rand($window.retro_height - width * 2 - 16) + width + 16,
             0]

      if distance(*pos[0..1], parent.altar.x, parent.altar.y) > 32 and
          parent.objects.map {|other| distance(*pos[0..1], other.x, other.y) }.min > 16
        return pos
      end
    end
  end

  # The object has been sacrificed at an altar.
  def sacrificed(actor, altar)
    @sacrificial_explosion.emit([altar.x, altar.y, altar.z + altar.height]) if @sacrificial_explosion
    destroy
  end

  def pause!
    reset_forces
    super
  end

  # Object has come to a halt.
  def on_stopped

  end

  # Object has bounced off the ground.
  def on_bounced

  end

  def destroy
    super

    @parent.space.remove_shape @shape
    @parent.space.remove_body @body

    if @parent.network and local?
      @parent.network.broadcast_msg(Message::Destroy.new(self))
    end
  end
end
module Wrath

require 'forwardable'

class BaseObject < GameObject
  include Log
  include Fidgit::Event
  include R18n::Helpers
  extend R18n::Helpers
  extend Forwardable

  unless defined? TERMINAL_VELOCITY
    TERMINAL_VELOCITY = -3  # Max velocity of a dropped item.
    FORCE_MODIFIER = 1440000.0 * Level::IDEAL_PHYSICS_STEP * 1.25
  end

  @@next_object_id = 0
  @@animation_cache = {}
  @@default_images = {}

  event :on_stopped # Has stopped bouncing.

  attr_reader :frames, :elasticity
  attr_writer :local
  attr_accessor :z, :x_velocity, :y_velocity, :z_velocity

  # The unique identifier of the object (or nil if not a networked object). Networked objects have consistent id on all machines.
  attr_reader :id

  # Not destroyed.
  def exists?; !!@parent; end
  def zorder; y; end
  def controlled_by_player?; false; end
  def casts_shadow?; @casts_shadow; end
  def affected_by_gravity?; true; end
  def remote?; not @local; end
  def local?; @local; end
  def controlled_by_player?; false; end
  def networked?; !!@id; end
  def media_folder; 'objects'; end
  def base_favor; @favor; end
  def favor; parent and parent.god ? parent.god.favor_for(self) : @favor; end

  # Should #destroy be propagated over the network?
  def network_destroy?; @id and parent.host?; end

  # Should #create be propagated over the network?
  def network_create?; @id and parent.host?; end

  # Should the object's location and velocity be propagated over the network?
  def network_sync?; @id and @local and parent.networked?; end

  def self.reset_object_ids; @@next_object_id = 0; end

  def_delegators :@body_position, :x, :y, :x=, :y=

  def_delegators :@body, :reset_forces

  def position; [x, y, @z]; end
  def position=(coordinates); @body_position.x, @body_position.y, @z = coordinates; end
  def velocity; [@x_velocity, @y_velocity, @z_velocity]; end
  def stationary?; velocity == [0, 0, 0]; end
  def moving?; velocity != [0, 0, 0]; end
  def velocity=(vector); @x_velocity, @y_velocity, @z_velocity = vector; end

  def self.default_image; @@default_images[self]; end

  def to_s; "#{self.class.name[/[^:]+$/]}##{networked? ? @id : object_id}"; end

  public
  def initialize(options = {})
    options = {
      rotation_center: :bottom_center,
      spawn: (not ([:x, :y, :z, :position].find {|p| options.has_key?(p) })),
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
      sacrifice_particle: Droplet,
      sacrifice_speed: 1.5,
      shape: :rectangle,
    }.merge! options

    # Face either direction, unless specified.
    unless options[:factor_x] or options[:factor]
      options[:factor_x] = rand() < 0.5 ? -1 : 1
    end

    @favor = options[:favor]

    if options[:animation].is_a? Animation
      @frames = options[:animation]
      width, height = @frames[0].width, @frames[0].height
    else
      # Cache animations to stop loading them ENDLESSLY!
      @@animation_cache[options[:animation]] ||= Animation.new(file: File.join(media_folder, options[:animation]))
      @frames = @@animation_cache[options[:animation]].dup # Duplicate structure, not images.
      options[:animation] =~ /(\d+)x(\d+)/
      width, height = $1.to_i, $2.to_i
    end

    @@default_images[self.class] = @frames[0]

    @frames.delay = 0 # Don't animate by default.

    options[:image] = @frames[0]

    width = options[:radius] ? options[:radius] * 2 : width

    init_physics(options[:x], options[:y], width, height, options[:collision_type], options[:shape], options[:mass])

    @z = options[:z]
    @elasticity = options[:elasticity]
    @casts_shadow = options[:casts_shadow]
    @sacrifice_particle = options[:sacrifice_particle]
    @sacrifice_speed = options[:sacrifice_speed]

    super(options)

    self.velocity = options[:velocity] || [options[:x_velocity], options[:y_velocity], options[:z_velocity]]
    self.position = options[:position] || [options[:x], options[:y], options[:z]]

    spawn if options[:spawn]

    if options.has_key? :id
      @id = options[:id]
      @@next_object_id = @id + 1 if @id # Ready for creating the next simultaneous object.
      @local = options[:local] || false
    else
      @id = @@next_object_id
      @@next_object_id += 1
      @local = options.has_key?(:local) ? options[:local] : true
      # Todo: This is horrid!
      if network_create?
        @parent.send_message(Message::Create.new(self.class, recreate_options))
      end
    end

    log.debug { "Created network object #{self}" } if @id

    @tile = nil

    @needs_sync = false
    @previous_position = position
    @previous_velocity = velocity

    @parent.space.add_body @body unless @body.mass == Float::INFINITY
    @parent.space.add_shape @shape
  end

  public
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
    case collision_type
      when :scenery
        @shape.layers = 0 # Doesn't interact with anything.
      when :static
        @shape.group = CollisionGroup::STATIC
      when :particle
        @shape.group = CollisionGroup::PARTICLE
    end

    @shape.object = self
  end

  public
  def sync(position, velocity)
    self.position = position
    self.velocity = velocity
  end

  protected
  def recreate_options
    {
      id: id,
      position: position,
      velocity: velocity,
      factor_x: factor_x
    }
  end

  public
  def can_spawn_onto?(tile)
    not (tile.is_a? Water or tile.is_a? Lava)
  end

  public
  def spawn
    self.position = parent.next_spawn_position(self)
  end

  public
  def draw
    if z < 0
      # Clip bottom of sprite, but allow shadow to still be seem (sticks out horizontally)
      $window.clip_to(0, 0, 10000, y) do
        draw_self
      end
    else
      draw_self
    end
  end

  protected
  def draw_self
    # Draw a shadow
    if casts_shadow?
      color = Color.rgba(0, 0, 0, (alpha * 0.7).to_i)

      shadow_scale = 0.5
      shadow_height = height * shadow_scale
      shadow_base = z * shadow_scale
      skew = shadow_height * shadow_scale

      top_left = [x + skew + (z * shadow_scale), y - shadow_height - shadow_base, color]
      top_right = [x + skew + width + (z * shadow_scale), y - shadow_height - shadow_base, color]
      bottom_left = [x - (width - z) * shadow_scale, y - shadow_base, color]
      bottom_right = [x + (width + z) * shadow_scale, y - shadow_base, color]

      if factor_x > 0
        image.draw_as_quad(*top_left, *top_right, *bottom_left, *bottom_right, ZOrder::SHADOWS)
      else
        image.draw_as_quad(*top_right, *top_left, *bottom_right, *bottom_left, ZOrder::SHADOWS)
      end
    end

    @image.draw_rot(x, y - z, zorder, 0, center_x, center_y, @factor_x, @factor_y, @color, @mode)
  end

  protected
  def ground_level
    @tile ? @tile.ground_level : 0
  end

  public
  def update
    return unless exists?

    # Check which tile we start on.
    @old_tile = @tile

    @tile = parent.tile_at_coordinate(x, y)
    if @tile.nil?
      log.warn { "#{self.class} found outside the map, at [#{x}, #{y}] - destroyed" }
      destroy
      return
    end

    @tile.touched_by(self) unless @tile.nil? or z > 0

    return unless exists? # Could have been destroyed, for example by touching lava.

    @z = ground_level if z <= ground_level

    # Deal with vertical physics manually.
    if @z_velocity != 0 or @z > ground_level
      if affected_by_gravity?
        @z_velocity += parent.gravity * frame_time
        @z_velocity = [@z_velocity, TERMINAL_VELOCITY].max
      end

      @z += @z_velocity

      if @z <= ground_level
        @z = ground_level
        @z_velocity = - @z_velocity * elasticity if @z_velocity < 0

        if @z_velocity < 0.2
          self.velocity = [0, 0, 0]
          halt
        end
      end
    end

    return unless exists? # Could have been destroyed, for example by stopping moving.

    # Set facing based on direction of movement.
    if (factor_x > 0 and x_velocity < 0) or
        (factor_x < 0 and x_velocity > 0)
      self.factor_x *= -1
    end

    super
  end

  protected
  def frame_time
    parent.frame_time
  end

  public
  def update_forces
    @body.reset_forces
    return if paused?

    # Apply a pushing force if the object is moving.
    if [@x_velocity, @y_velocity] != [0, 0]
      modifier = FORCE_MODIFIER
      modifier *= @tile.speed if z <= 0 and @tile
      @body.apply_force(vec2(@x_velocity * modifier, @y_velocity * modifier),
                        vec2(0, 0))
    end
  end

  public
  def set_body_velocity(angle, force)
    @x_velocity = offset_x(angle, 1) * force
    @y_velocity = offset_y(angle, 1) * force
  end


  public
  # The object has been sacrificed at an altar.
  def sacrificed(actor, altar)
    self.position = [altar.x, altar.y, altar.z + altar.height]
    explode(@sacrifice_particle, parent).each do |particle|
      angle = rand(360)
      speed = rand() * @sacrifice_speed
      particle.velocity = [
          Math::sin(angle) * speed,
          Math::cos(angle) * speed,
          rand() * @sacrifice_speed
      ]
    end
  end

  public
  def pause!
    reset_forces
    super
  end

  public
  # Called when the object stops moving.
  def halt
    #parent.send_message(Message::Stop.new(self)) if networked? and parent.host?
    self.velocity = [0, 0, 0]
    publish :on_stopped
  end

  # Shatter the object into its component pixel fragments.
  public
  def explode(type, parent)
    no_color = Color.rgb(255, 255, 255)
    fragments = []

    image.explosion.each do |color, x, y|
      effective_color = if self.color == no_color
                          color.dup
                        else
                          self.color.dup
                        end

      # Allow for direction of facing.
      x = factor_x > 0 ? (self.x - width / 2.0 + x) : (self.x + width / 2.0 - x)

      fragments << type.create(x: x,
                  y: self.y,
                  z: z + height - y,
                  color: effective_color,
                  parent: parent)
    end

    fragments
  end

  public
  def destroy
    unless exists?
      if networked?
        log.warn { "Attempting to destroy an already destroyed network object #{self}" }
      else
        log.warn { "Attempting to destroy an already destroyed object #{self}" }
      end

      return
    end

    super

    log.debug { "Destroyed network object #{self}" } if @id

    @parent.space.remove_shape @shape
    @parent.space.remove_body @body

    if network_destroy?
      @parent.send_message(Message::Destroy.new(self))
    end

    @parent = nil # The object no longer exists, so should not be linked to the scene.
  end
end
end
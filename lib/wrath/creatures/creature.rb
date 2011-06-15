module Wrath

  # Any sort of living being.
class Creature < Container
  extend Forwardable

  include Fidgit::Event
  include HasStatus

  event :on_wounded

  trait :timer

  ACTION_DISTANCE = 12

  EXPLOSION_H_SPEED = 0.04..0.5
  EXPLOSION_Z_VELOCITY = 0.1..0.3

  WOUND_FLASH_PERIOD = 200
  AFTER_WOUND_FLASH_DURATION = 100
  HURT_COLOR = Color.rgba(255, 0, 0, 150)

  WALK_ANIMATION_DELAY = 200
  STAND_UP_DELAY = 1000
  FRAME_WALK1 = 0
  FRAME_WALK2 = 1
  FRAME_LIE = 2
  FRAME_THROWN = 2
  FRAME_MOUNTED = 0
  FRAME_CARRIED = 2
  FRAME_DEAD = 3

  THROW_BASE_SPEED = 1.5
  THROW_MOVING_SPEED_MULTIPLIER = 3.5 # Speed things are thrown at, compared to own speed.

  KNOCK_DOWN_SPEED_V  = 0.75
  KNOCK_DOWN_SPEED_H = 3

  PLAYER_STAND_UP_DELAY = 750 # Don't annoy the player.
  CREATURE_STAND_UP_DELAY = 2000 # Give the player time to grab the creature.

  HEALTH_BAR_BACKGROUND = Color.rgba(0, 0, 0 ,100)
  HEALTH_BAR_FOREGROUND = Color::RED
  HEALTH_BAR_THICKNESS = 0.5

  DAZED_STAR_SIZE = 0.75
  DAZED_STAR_ANGLE = 60
  DAZED_STAR_SPEED = 0.1
  DAZED_STAR_COLOR = Color.rgba(255, 255, 0, 150)

  attr_reader :state, :speed, :health, :player, :max_health, :facing, :strength
  attr_reader :flying_rise_speed, :flying_height

  attr_writer :player, :state, :strength, :speed, :flying_rise_speed, :flying_height

  alias_method :carrying?, :full?
  alias_method :empty_handed?, :empty?

  def media_folder; 'creatures'; end
  def mount?; false; end
  def alive?; @health > 0; end
  def dead?; @health <= 0; end
  def facing=(angle); @facing = angle % 360; end
  def controlled_by_player?; false; end
  def can_be_picked_up?(container); ((@state == :lying) or (not hurts?(container) and not controlled_by_player?)) and super; end
  def stand_up_delay; controlled_by_player? ? PLAYER_STAND_UP_DELAY : CREATURE_STAND_UP_DELAY; end
  def can_hit?(other)
    super(other) and upright?
  end

  # Creatures don't bounce much if thrown. Usual elasticity only used in movement.
  def elasticity; thrown? ? [0.3, super].min : super; end
  def walking_to_do?; @walk_time_left > 0; end

  def affected_by_gravity?; super and not (flying_height > 0 and upright?); end
  def prone?; [:lying, :thrown].include? state; end
  def upright?; not prone?; end

  public
  def initialize(options = {})
    options = {
        flying_height: 0,
        flying_rise_speed: 0.5,
        health: 10000,
        strength: 1.0,
        z_offset: -2,
        facing: 0,
        sacrifice_particle: BloodDroplet,
        move_interval: 2000,
    }.merge! options

    super options

    @flying_height = options[:flying_height]
    @flying_rise_speed = options[:flying_rise_speed]
    @max_health = @health = options[:health]

    @strength = options[:strength]
    @facing = options[:facing]

    @move_interval = options[:move_interval]

    # For walkers:
    @walk_duration = options[:walk_duration]
    @speed = options[:speed]
    @walk_time_left = 0

    # For jumpers:
    @vertical_jump = options[:vertical_jump]
    @horizontal_jump = options[:horizontal_jump]

    self.move_type = options[:move_type]

    @death_explosion = Emitter.new(BloodDroplet, parent, number: ((favor / 5) + 4), h_speed: EXPLOSION_H_SPEED,
                                            z_velocity: EXPLOSION_Z_VELOCITY)

    @state = :standing

    @first_wounded_at = @last_wounded_at = nil

    @walking_animation = @frames[FRAME_WALK1..FRAME_WALK2]
    @walking_animation.delay = WALK_ANIMATION_DELAY

    # Start flying if possible, otherwise find ground level.
    self.z = (@flying_height > 0) ? @flying_height : ground_level

    schedule_move
  end

  public
  def move_type=(value)
    @move_type = value

    case @move_type
      when :walk
        raise ":walk_duration and :speed required for walkers" unless @walk_duration and @speed
        raise ":move_interval required" unless @move_interval
      when :jump
        raise ":vertical_jump and :horizontal_jump required for walkers" unless @vertical_jump and @horizontal_jump
        raise ":move_interval required" unless @move_interval
      when :none
        nil
      else
        raise "unknown :move_type: #{@move_type}"
    end
  end

  public
  def die!
    # Create a corpse to replace this fellow. This will be created simultaneously on all machines, using the next available id.
    corpse = Corpse.create(parent: parent, animation: @frames[FRAME_DEAD..FRAME_DEAD], z_offset: z_offset,
                  encumbrance: encumbrance, position: position, velocity: velocity,
                  emitter: @death_explosion, local: (not parent.client?),
                  factor_x: factor_x, factor_y: factor_y)

    drop unless empty_handed?

    @death_explosion.emit([x, y, z + height / 2], thrown_by: [self, corpse]) if @death_explosion

    parent.lose!(player) if player and not parent.winner

    destroy
  end

  protected
  def schedule_move
    if local? and not controlled_by_player?
      after(@move_interval + (rand(@move_interval / 2.0) + rand(@move_interval / 2.0)), name: :move) do
        if local? and not controlled_by_player?
          if @state == :standing
            start_moving
          else
            schedule_move
          end
        end
      end
    end
  end

  protected
  def start_moving
    case @move_type
      when :walk then start_walking
      when :jump then start_jumping
      when :none then nil
    end
  end

  protected
  def start_jumping
    self.facing = rand(360)
    @z_velocity = random(@vertical_jump * 0.75, @vertical_jump * 1.25)
    h_jump = random(@horizontal_jump * 0.75, @horizontal_jump * 1.25)
    @y_velocity = Math::sin(facing) * h_jump
    @x_velocity = Math::cos(facing) * h_jump
  end

  protected
  def start_walking
    self.state = :walking
    self.facing = rand(360)
    @walk_time_left = random(@walk_duration * 0.5, @walk_duration * 1.5)
  end

  protected
  def on_wounded(sender, damage)
    if controlled_by_player? and damage >= 2
      # TODO: Need a better way to avoid making sound for DOT.
      Sample["creatures/hurt.ogg"].play_at_x(x)
    end

    # Try to move away from pain.
    if timer_exists? :move
      stop_timer(:move)
      start_moving
    end
  end

  protected
  def draw_self
    super

    # Draw a red overlay to show when you are wounded.
    if @overlay_color
      image.silhouette.draw_rot(x, y - z, y, 0, center_x, center_y, factor_x, factor_y, @overlay_color)
    end

    # Draw a health bar, but only if injured.
    if health < max_health and not inside_container?
      bar_x = x - (width / 2)
      bar_z = z + height + 2 + (empty_handed? ? 0 : contents.height + contents.z_offset)
      health_width = width * health / max_health.to_f
      $window.pixel.draw_rot bar_x, y - bar_z, y, 0, 0, 1, width, HEALTH_BAR_THICKNESS, HEALTH_BAR_BACKGROUND
      $window.pixel.draw_rot bar_x, y - bar_z, y, 0, 0, 1, health_width, HEALTH_BAR_THICKNESS, HEALTH_BAR_FOREGROUND
    end

    draw_dazed if state == :lying
  end

  protected
  # Draw dazed stars.
  def draw_dazed
    offset = (milliseconds * DAZED_STAR_SPEED) % DAZED_STAR_ANGLE
    pixel = $window.pixel
    radius = [width, height].min * 0.3
    ((0 + offset)...(360 + offset)).step(DAZED_STAR_ANGLE) do |angle|
      star_x = x + offset_x(angle, radius) + ((factor_x > 0) ? dazed_offset_x : -dazed_offset_x)
      star_y = y + offset_y(angle, radius) * 0.5
      star_z = z + height
      pixel.draw star_x, star_y - star_z, star_y, DAZED_STAR_SIZE, DAZED_STAR_SIZE, DAZED_STAR_COLOR
    end
  end

  public
  def health=(value)
    original_health = @health
    @health = [[value, 0].max, max_health].min

    if @health < original_health
      @last_wounded_at = milliseconds
      @first_wounded_at = @last_wounded_at unless @first_wounded_at
    end

    # Synchronise health from the server to the client.
    if @health != original_health and parent.host?
      parent.send_message(Message::SetHealth.new(self))
    end

    die! if @health == 0

    if @health < original_health
      publish :on_wounded, original_health - @health
    end

    @health
  end

  public
  def stand_up
    if @state == :lying
      parent.send_message(Message::StandUp.new(self)) if parent.host?
      @state = :standing
      schedule_move unless parent.client?
    else
      log.warn "#{self} told to stand up when not lying down (#{state.inspect})"
    end
  end

  protected
  def effective_speed
    contents ? (@speed * ([strength - contents.encumbrance, 1].min)) : @speed
  end

  public
  def on_having_dropped(object)
    if alive?                                      #
      if (x_velocity == 0 and y_velocity == 0)
        # Give a little push if you are stationary, so that it doesn't just land at their feet.
        object.x_velocity = factor_x * THROW_BASE_SPEED
      else
        object.x_velocity = x_velocity * THROW_MOVING_SPEED_MULTIPLIER
        object.y_velocity = y_velocity * THROW_MOVING_SPEED_MULTIPLIER
      end

      object.z_velocity = z_velocity
    end

    nil
  end

  public
  def local=(value)
    # Player avatar never change locality.
    super(value) unless controlled_by_player?
  end

  public
  def mount(mount)
    mount.pick_up(self)
  end

  public
  # The creature's ghost has ascended, after sacrifice.
  def ghost_disappeared

  end

  public
  # The creature tries to perform an action, at the will of a Player.
  def action
    # Find all objects within range, then check them in order
    # and activate the first on we can (generally, pick it up).
    near_objects = parent.objects - [self]
    near_objects.select! {|g| distance_to(g) <= ACTION_DISTANCE }
    near_objects.sort_by! {|g| distance_to(g) }

    target = near_objects.find {|o| o.can_be_activated?(self) }

    # Special case if we are carrying something that we can't drop.
    if not target and not empty_handed? and not @contents.can_be_dropped?
      return
    end

    if parent.client?
      # Client needs to ask permission first.
      parent.send_message(Message::RequestAction.new(self, target))
      # Host/local can do it immediately.
    else
      perform_action(target)
    end
  end

  protected
  def sync_state
    # Ensure that state is updated remotely.
    case @state
      when :standing
        @state = :walking if [x_velocity, y_velocity] != [0, 0]
      when :walking
        halt if [x_velocity, y_velocity] == [0, 0]
    end
  end

  public
  def update
    return unless exists?

    if @move_type == :walk and local? and @state == :walking and not controlled_by_player?
      if walking_to_do?
        move(facing)
        @walk_time_left -= frame_time
      else
        halt
      end
    end

    # Float upwards if flying.
    if flying_height > 0 and upright?
      if z >= flying_height
        self.z = flying_height
        self.z_velocity = 0
      else
        self.z_velocity = [[flying_height - z, 0].max, 2].min * 0.5 * flying_rise_speed
      end
    end

    super

    sync_state

    update_color

    # Ensure any carried object faces in the same direction as the player.
    if carrying?
      if (factor_x > 0 and contents.factor_x < 0) or
          (factor_x < 0 and contents.factor_x > 0)
        contents.factor_x *= -1
      end
    end

    self.image = case state
                   when :walking
                     @walking_animation.next
                   when :standing
                     @frames[FRAME_WALK1]
                   when :carried
                     @frames[FRAME_CARRIED]
                   when :mounted
                     @frames[FRAME_MOUNTED]
                   when :lying
                     @frames[FRAME_LIE]
                   when :thrown
                     @frames[FRAME_THROWN]
                   else
                     raise "unknown state: #{state}"
                 end
  end

  protected
  def on_being_picked_up(container)
    super(container)
    @state = (container.is_a?(Creature) and container.mount?) ? :mounted : :carried
    drop
    stop_timer :stand_up
    stop_timer :move
  end

  protected
  def on_being_dropped(container)
    super(container)
    remove_status(:anointed) if anointed?
    @state = :thrown
  end

  public
  def move(angle)
    self.state = :walking
    angle += status(:poisoned).displacement_angle if poisoned?
    set_body_velocity(angle, effective_speed)
  end

  public
  def on_collision(other)
    case other
      when Wall
        if not inside_container? and not controlled_by_player?
          case @move_type
            when :walk then rotate_walker_at_wall(other)
            when :jump, :none then rotate_jumper_at_wall(other)
          end
        end

        true

      when DynamicObject
        # Make being hit with something heavy knock you over.
        if upright? and other.can_knock_down_creature?(self) and
            other.thrown_by.any? {|o| o.is_a? Creature } # So items popping out of chests don't knock you down.

          knocked_down_by(other)

        elsif other.hurts?(self)
          if other.can_hit?(self)
            # Hurt things that we don't like in a big one-off strike.
            wound(other.damage_per_hit, other, :hit)
          elsif other.damage_per_second > 0
            # Hurt things that we don't like over time, for example by fire. Only happens if
            # we didn't hit them.
            wound(other.damage_per_second * Level::IDEAL_PHYSICS_STEP, other, :over_time)
          end
        end

        false

      when StaticObject
        # Turn if we are walking into a static. 1000 degrees/second.
        @facing += 0.001 * Level::IDEAL_PHYSICS_STEP unless controlled_by_player?

        true

      else
        super(other)
    end
  end


  protected
  def rotate_walker_at_wall(wall)
    # Bounce back from the edge of the screen
    case wall.side
      when :right
        self.facing = (360 - facing) if x_velocity > 0
      when :left
        self.facing = (360 - facing) if x_velocity < 0
      when :top
        self.facing = (180 - facing) if y_velocity < 0
      when :bottom
        self.facing = (180 - facing) if y_velocity > 0
      else
        raise "bad side"
    end
  end

  protected
  def rotate_jumper_at_wall(wall)
    case wall.side
      when :right
        self.x_velocity = - self.x_velocity * elasticity * 0.5 if x_velocity > 0
      when :left
        self.x_velocity = - self.x_velocity * elasticity * 0.5 if x_velocity < 0
      when :top
        self.y_velocity = - self.y_velocity * elasticity * 0.5 if y_velocity < 0
      when :bottom
        self.y_velocity = - self.y_velocity * elasticity * 0.5 if y_velocity > 0
      else
        raise "bad side"
    end
  end

  public
  def wound(damage, wounder, type)
    raise ArgumentError.new("bad type: #{type.inspect}") unless [:hit, :over_time].include? type

    if local? and controlled_by_player?
      stats = parent.statistics
      wounder_name = wounder.class.name[/[^:+]+$/].to_sym

      stats[:damage, :total] = (stats[:damage, :total] || 0) + damage
      stats[:damage, :type, wounder_name] = (stats[:damage, :type, wounder_name] || 0) + damage

      if damage >= health
        stats.increment(:deaths, :total)
        stats.increment(:deaths, :type, wounder_name)
      end
    end

    self.health -= damage

    if alive? and type == :hit
      knocked_down_by(wounder)
    end

    self
  end

  public
  # You were knocked down by someone else.
  def knocked_down_by(knocker)
    parent.send_message(Message::KnockedDown.new(self, knocker)) if parent and parent.host?

    @state = :thrown
    @thrown_by += [knocker] + knocker.thrown_by
    @thrown_by << knocker.container if knocker.container and knocker.container.mount?
    drop unless empty_handed?

    angle = Gosu::angle(knocker.x, knocker.y, x, y)
    self.velocity = [offset_x(angle, KNOCK_DOWN_SPEED_H), offset_y(angle, KNOCK_DOWN_SPEED_H), KNOCK_DOWN_SPEED_V]

    stop_timer :move
    knocker.knocked_someone_down(self)

    nil
  end

  protected
  def update_color
    # Reset colour if it was a while since we were wounded.
    if @first_wounded_at
      if milliseconds - @last_wounded_at > AFTER_WOUND_FLASH_DURATION
        @overlay_color = nil
        @first_wounded_at = @last_wounded_at = nil
      else
        if (milliseconds - @first_wounded_at).div(WOUND_FLASH_PERIOD) % 2 == 0
          @overlay_color = HURT_COLOR
        else
          @overlay_color = nil
        end
      end
    end
  end

  public
  def halt
    case @state
      when :thrown
        # Lie down then stand up if we were thrown.
        @state = :lying
        after(stand_up_delay, name: :stand_up) { stand_up } unless parent.client?
      else
        @walk_time_left = 0
        self.state = :standing

        # Has been jumping or walking, but come to a stand-still.
        stop_timer :move if timer_exists? :move
        schedule_move
    end

    super
  end
end
end
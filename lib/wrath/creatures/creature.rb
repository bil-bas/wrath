# encoding: utf-8

class Creature < Carriable
  trait :timer

  ACTION_DISTANCE = 10

  WOUND_FLASH_PERIOD = 200
  AFTER_WOUND_FLASH_DURATION = 100
  POISON_COLOR = Color.rgba(0, 200, 0, 150)
  HURT_COLOR = Color.rgba(255, 0, 0, 150)

  WALK_ANIMATION_DELAY = 200
  STAND_UP_DELAY = 1000
  FRAME_WALK1 = 0
  FRAME_WALK2 = 1
  FRAME_LIE = 2
  FRAME_THROWN = 2
  FRAME_CARRIED = 2
  FRAME_SLEEP = 3
  FRAME_DEAD = 3

  attr_reader :state, :speed, :favor, :health, :carrying, :player, :max_health

  attr_writer :player

  def alive?; @health > 0; end
  def dead?; @health <= 0; end
  def carrying?; not @carrying.nil?; end
  def empty_handed?; @carrying.nil?; end
  def poisoned?; @poisoned; end

  def initialize(options = {})
    options = {
        health: 10000,
        poisoned: false,
    }.merge! options

    super options

    @max_health = @health = options[:health]
    @speed = options[:speed]
    @poisoned = options[:poisoned]

    @carrying = nil
    @state = :standing
    @player = nil

    @first_wounded_at = @last_wounded_at = nil

    @walking_animation = @frames[FRAME_WALK1..FRAME_WALK2]
    @walking_animation.delay = WALK_ANIMATION_DELAY
  end

  def die!
    reset_color
    reset_forces
    drop
    @state = :dead
    self.image = @frames[FRAME_DEAD]
    parent.lose!(player) if player and not parent.winner
  end

  def draw_self
    super

    if @overlay_color
      image.silhouette.draw_rot(x, y - z, y - z, 0, center_x, center_y, factor_x, factor_y, @overlay_color)
    end
  end

  def health=(value)
    original_health = @health
    @health = [[value, 0].max, max_health].min
    if @health == 0 and original_health > 0 and player and not parent.winner
      parent.lose!(player)
    end

    if @health < original_health
      @last_wounded_at = milliseconds
      @first_wounded_at = @last_wounded_at unless @first_wounded_at
    end

    @health
  end

  def effective_speed
    @carrying ? (@speed * (1 - @carrying.encumbrance)) : @speed
  end

  def drop
    return unless @carrying and @carrying.can_drop?

    dropping = @carrying
    @carrying = nil

    @parent.objects.push dropping

    # Give a little push if you are stationary, so that it doesn't just land at their feet.
    extra_x_velocity = (x_velocity == 0 and y_velocity == 0) ? factor_x * 0.2 : 0
    dropping.dropped(self, x_velocity * 1.5 + extra_x_velocity, y_velocity * 1.5, z_velocity + 0.5)

    if @parent.network.is_a? Server
      @parent.network.broadcast_msg(Message::Drop.new(self))
    end

    dropping
  end

  def pick_up(object)
    return unless object.can_pick_up?

    drop if carrying?

    parent.objects.delete object
    @carrying = object
    @carrying.picked_up(self)

    if (factor_x > 0 and @carrying.factor_x < 0) or
        (factor_x < 0 and @carrying.factor_x > 0)
      @carrying.factor_x *= -1
    end

    if @parent.network.is_a? Server
      @parent.network.broadcast_msg(Message::PickUp.new(self, @carrying))
    end
  end

  def action
    return if dead?

    # Find the nearest object and activate it (generally, pick it up)
    objects = parent.objects - [self]
    nearest = objects.min_by {|g| distance_to(g) }
    nearest = nil unless distance_to(nearest) <= ACTION_DISTANCE

    if nearest and nearest.can_be_activated?(self)
      if nearest.local?
        nearest.activate(self)
      else
        # ODO: Request activation from server.
      end
    elsif @carrying
      if @carrying.local?
        drop
      else
        # TODO: Request drop.
      end
    end
  end

  def update
    super

    update_color

    case @state
      when :standing
        @state = :walking if [x_velocity, y_velocity] != [0, 0]
      when :walking
        @state = :standing if velocity == [0, 0, 0]
    end

    # Ensure any carried object faces in the same direction as the player.
    if @carrying
      if (factor_x > 0 and @carrying.factor_x < 0) or
          (factor_x < 0 and @carrying.factor_x > 0)
        @carrying.factor_x *= -1
      end
    end

    self.image = case state
                   when :walking
                     z <= @tile.ground_level ? @walking_animation.next : @frames[FRAME_WALK1]
                   when :standing
                     @frames[FRAME_WALK1]
                   when :carried
                     @frames[FRAME_CARRIED]
                   when :lying
                     @frames[FRAME_LIE]
                   when :thrown
                     @frames[FRAME_THROWN]
                   when :sleeping
                     @frames[FRAME_SLEEP]
                   when :dead
                     @frames[FRAME_DEAD]
                   else
                     raise "unknown state: #{state}"
                 end
  end

  def picked_up(by)
    @state = :carried
    drop
    stop_timer :stand_up
    super(by)
  end

  def dropped(*args)
    @state = :thrown
    super(*args)
  end

  def reset_color
    if poisoned?
      @overlay_color = POISON_COLOR
    else
      @overlay_color = nil
    end
  end

  def poison(duration)
    # TODO: play gulping noise.
    @poisoned = true
    reset_color
    stop_timer(:cure_poison)
    after(duration, name: :cure_poison) { cure_poison }
  end

  def move(angle)
    angle += (Math::sin(milliseconds / 150) * 45) if poisoned?
    set_body_velocity(angle, effective_speed)
  end

  def cure_poison
    @poisoned = false
    reset_color
  end

  def update_color
    # Reset colour if it was a while since we were wounded.
    if @first_wounded_at
      if milliseconds - @last_wounded_at > AFTER_WOUND_FLASH_DURATION
        reset_color
        @first_wounded_at = @last_wounded_at = nil
      else
        if (milliseconds - @first_wounded_at).div(WOUND_FLASH_PERIOD) % 2 == 0
          @overlay_color = HURT_COLOR
        else
          reset_color
        end
      end
    end
  end

  def on_stopped
    case @state
      when :thrown
        # Stand up if we were thrown.
        after(STAND_UP_DELAY, name: :stand_up) { @state = :standing if @state == :thrown }
    end

    super
  end
end
# encoding: utf-8

class LocalPlayer < Player
  KEYS_CONFIG_FILE = File.join(ROOT_PATH, 'config', 'keys.yml')
  ACTION_DISTANCE = 10

  attr_reader :number

  def initialize( options = {})
    options = {
    }.merge! options

    @number = options[:number]

    keys_config = YAML.load(File.open(KEYS_CONFIG_FILE) {|f| f.read })

    keys = keys_config[:players][@number + 1]
    @keys_left = keys[:left]
    @keys_right = keys[:right]
    @keys_up = keys[:up]
    @keys_down = keys[:down]
    @keys_action = keys[:action]

    options[:gui_pos] = [[10, 0], [115, 0]][@number]

    super(options)

    on_input(@keys_action, :action) if local?
  end

  def effective_speed
    @carrying ? (@speed * (1 - @carrying.encumbrance)) : @speed
  end

  def opponent
    (parent.players - [self]).first
  end

  def die!
    parent.win!(opponent) unless parent.winner
    drop unless empty_handed?
    super
  end

  def update
    move_by_keys if local? and alive?

    if x_velocity == 0 and y_velocity == 0
      @state = :standing
    else
      @state = :walking
    end

    # Ensure any carried object faces in the same direction as the player.
    if @carrying
      if (factor_x > 0 and @carrying.factor_x < 0) or
          (factor_x < 0 and @carrying.factor_x > 0)
        @carrying.factor_x *= -1
      end
    end

    super
  end

  def move_by_keys
    if holding_any? *@keys_left
      if holding_any? *@keys_up
        # NW
        move(315)
      elsif holding_any? *@keys_down
        # SW
        move(225)
      else
        # W
        move(270)
      end
    elsif holding_any? *@keys_right
      if holding_any? *@keys_up
        # NE
        move(45)
      elsif holding_any? *@keys_down
        # SE
        move(135)
      else
        # E
        move(90)
      end
    elsif holding_any? *@keys_up
      # N
      move(0)
    elsif holding_any? *@keys_down
      # S
      move(180)
    else
      set_body_velocity(0, 0)
      # Standing entirely still.
    end
  end

  def move(angle)
    set_body_velocity(angle, effective_speed)
  end

  def drop(object = @carrying)
    @parent.objects.push object

    # Give a little push if you are stationary, so that it doesn't just land at their feet.
    extra_x_velocity = (x_velocity == 0 and y_velocity == 0) ? factor_x * 0.2 : 0
    object.drop(self, x_velocity * 1.5 + extra_x_velocity, y_velocity * 1.5, z_velocity + 0.5)

    if @parent.network.is_a? Server
      @parent.network.broadcast_msg(Message::Drop.new(self))
    end
  end

  def action
    return if dead?

    # Find the nearest object and activate it (generally, pick it up)
    objects = @parent.objects - [self]
    nearest = objects.min_by {|g| distance_to(g) }
    nearest = nil unless distance_to(nearest) <= ACTION_DISTANCE

    if nearest and nearest.can_be_activated?(self)
      if nearest.local?
        nearest.activate(self)
      else
        # TODO: Request activation from server.
      end
    elsif @carrying
      if @carrying.local?
        dropping = @carrying
        @carrying = nil
        drop(dropping)
      else
        # TODO: Request drop.
      end
    end
  end

  def pick_up(object)
    parent.objects.delete object
    @carrying = object
    @carrying.pick_up(self)

    if (factor_x > 0 and @carrying.factor_x < 0) or
        (factor_x < 0 and @carrying.factor_x > 0)
      @carrying.factor_x *= -1
    end

    if @parent.network.is_a? Server
      @parent.network.broadcast_msg(Message::PickUp.new(self, @carrying))
    end
  end
end
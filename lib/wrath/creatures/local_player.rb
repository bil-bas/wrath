# encoding: utf-8

class LocalPlayer < Player
  KEYS_CONFIG_FILE = File.join(ROOT_PATH, 'config', 'keys.yml')
  ACTION_DISTANCE = 10
  DIAGONAL_SPEED = Math.sqrt(2) / 2

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

    options[:gui_pos] = [[10, 110], [80, 110]][@number]

    super(options)

    on_input(@keys_action, :action) if local?
  end

  def effective_speed
    @carrying ? (@speed * (1 - @carrying.encumbrance)) : @speed
  end

  def update
    move_by_keys if local?

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
        self.x_velocity = -effective_speed * DIAGONAL_SPEED
        self.y_velocity = -effective_speed * DIAGONAL_SPEED
      elsif holding_any? *@keys_down
        # SW
        self.x_velocity = -effective_speed * DIAGONAL_SPEED
        self.y_velocity = effective_speed * DIAGONAL_SPEED
      else
        # W
        self.y_velocity = 0
        self.x_velocity = -effective_speed
      end
    elsif holding_any? *@keys_right
      if holding_any? *@keys_up
        # NE
        self.x_velocity = effective_speed * DIAGONAL_SPEED
        self.y_velocity = -effective_speed * DIAGONAL_SPEED
      elsif holding_any? *@keys_down
        # SE
        self.x_velocity = effective_speed * DIAGONAL_SPEED
        self.y_velocity = effective_speed * DIAGONAL_SPEED
      else
        # E
        self.y_velocity = 0
        self.x_velocity = effective_speed
      end
    elsif holding_any? *@keys_up
      # N
      self.x_velocity = 0
      self.y_velocity = -effective_speed
    elsif holding_any? *@keys_down
      # S
      self.x_velocity = 0
      self.y_velocity = effective_speed
    else
      # Standing entirely still.
      self.x_velocity = self.y_velocity = 0
    end
  end

  def drop(object = @carrying)
    $window.current_game_state.objects.push object

    # Give a little push if you are stationary, so that it doesn't just land at their feet.
    extra_x_velocity = (x_velocity == 0 and y_velocity == 0) ? factor_x * 0.2 : 0
    object.drop(self, x_velocity * 2 + extra_x_velocity, y_velocity * 2, z_velocity + 0.5)

    if @parent.network.is_a? Server
      @parent.network.broadcast_msg(Message::Drop.new(self))
    end
  end

  def action
    # Find the nearest object and activate it (generally, pick it up)
    objects = $window.current_game_state.objects - [self]
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
    $window.current_game_state.objects.delete object
    @carrying = object
    @carrying.pick_up(self, CARRY_OFFSET)

    if (factor_x > 0 and @carrying.factor_x < 0) or
        (factor_x < 0 and @carrying.factor_x > 0)
      @carrying.factor_x *= -1
    end

    if @parent.network.is_a? Server
      @parent.network.broadcast_msg(Message::PickUp.new(self, @carrying))
    end
  end
end
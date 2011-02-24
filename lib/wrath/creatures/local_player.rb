# encoding: utf-8

require_relative 'player'

class LocalPlayer < Player
  ACTION_DISTANCE = 10
  DIAGONAL_SPEED = Math.sqrt(2) / 2

  def initialize(options = {})
    options = {
      keys_up: :up,
      keys_down: :down,
      keys_left: :left,
      keys_right: :right,
      keys_action: :space,
    }.merge! options

    @keys_up = options[:keys_up]
    @keys_down = options[:keys_down]
    @keys_left = options[:keys_left]
    @keys_right = options[:keys_right]

    super(options)

    on_input(options[:keys_action], :action) if local?
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

    @carrying.factor_x = factor_x if @carrying

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
      self.x_velocity = self.y_velocity = 0
    end
  end

  def drop(object = @carrying)
    $window.current_game_state.objects.push object
    object.drop(self, factor_x * 0.5, 0, 0.5)

    if @parent.network.is_a? Server
      @parent.network.broadcast_msg(Message::Drop.new(actor: id))
    end
  end

  def action
    # Find the nearest object and activate it (generally, pick it up)
    objects = $window.current_game_state.objects - [self]
    nearest = objects.min_by {|g| distance_to(g) }
    nearest = nil unless distance_to(nearest) <= ACTION_DISTANCE

    if @carrying
      dropping = @carrying
      # Drop whatever we are carrying.
      case nearest
        when Altar
          if nearest.ready?
            @carrying = nil
            nearest.sacrifice(self, dropping)
          end

        when Chest
          @carrying = nil
          if nearest.open?
            nearest.close(dropping)
          else
            drop dropping
          end

        else
          @carrying = nil
          drop dropping

      end
    elsif nearest
      if nearest.is_a? Chest and nearest.closed?
        nearest.open
      else
        pick_up(nearest) if nearest.carriable?
      end
    end
  end

  def pick_up(object)
    $window.current_game_state.objects.delete object
    @carrying = object
    @carrying.pick_up(self, CARRY_OFFSET)
    @carrying.factor_x = factor_x

    if @parent.network.is_a? Server
      @parent.network.broadcast_msg(Message::PickUp.new(actor: id, object: @carrying.id))
    end
  end
end
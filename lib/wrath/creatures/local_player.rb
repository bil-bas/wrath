# encoding: utf-8

require_relative 'player'

class LocalPlayer < Player
  ACTION_DISTANCE = 10
  DIAGONAL_SPEED = Math.sqrt(2) / 2

  def initialize(options = {})
    options = {
    }.merge! options

    @keys_up = options[:keys_up]
    @keys_down = options[:keys_down]
    @keys_left = options[:keys_left]
    @keys_right = options[:keys_right]

    super(options)

    on_input(options[:keys_action], :action)
  end

  def effective_speed
    @carrying ? (@speed * (1 - @carrying.encumbrance)) : @speed
  end

  def update
    old_pos = [x, y]

     @state = :walking

    # Move the character.
    if holding_any? *@keys_left
      self.factor_x = -1

      if holding_any? *@keys_up
        self.x -= effective_speed * DIAGONAL_SPEED
        self.y -= effective_speed * DIAGONAL_SPEED
      elsif holding_any? *@keys_down
        self.x -= effective_speed * DIAGONAL_SPEED
        self.y += effective_speed * DIAGONAL_SPEED
      else
        self.x -= effective_speed
      end
    elsif holding_any? *@keys_right
      self.factor_x = 1

      if holding_any? *@keys_up
        self.x += effective_speed * DIAGONAL_SPEED
        self.y -= effective_speed * DIAGONAL_SPEED
      elsif holding_any? *@keys_down
        self.x += effective_speed * DIAGONAL_SPEED
        self.y += effective_speed * DIAGONAL_SPEED
      else
        self.x += effective_speed
      end
    elsif holding_any? *@keys_up
      self.y -= effective_speed
    elsif holding_any? *@keys_down
      self.y += effective_speed
    else
      @state = :standing
    end

    @carrying.factor_x = factor_x if @carrying

    # Keep co-ordinates inside the screen.
    self.x = [[x, $window.retro_width - (width / (2 * factor))].min, width / (2 * factor)].max
    self.y = [[y, $window.retro_height].min, height / factor].max

    if [x, y] != old_pos
      # broadcast our new position.
    end

    super
  end

  def drop(object)
    $window.current_game_state.objects.push object
    object.drop(self, factor_x * 0.5, 0, 0.5)
  end

  def action
    # Find the nearest object and activate it (generally, pick it up)
    objects = $window.current_game_state.objects
    p ["@carrying", @carrying]
    nearest = objects.min_by {|g| distance_to(g) }
    nearest = nil unless distance_to(nearest) <= ACTION_DISTANCE

    p ["nearest", nearest]

    if @carrying
      dropping = @carrying
      # Drop whatever we are carrying.
      case nearest
        when Altar
          p ["nearest.ready?", nearest.ready?]
          if nearest.ready?
            @carrying = nil
            nearest.sacrifice(self, dropping)
          end

        when Chest
          @carrying = nil
          p ["nearest.open?", nearest.open?]
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
        pick_up(nearest)        
      end
    end
  end

  def pick_up(object)
    $window.current_game_state.objects.delete object
    @carrying = object
    @carrying.pick_up(self, CARRY_OFFSET)
    @carrying.factor_x = factor_x
  end
end
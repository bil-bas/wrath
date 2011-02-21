require_relative 'player'

class LocalPlayer < Player
  ACTION_DISTANCE = 10
  CARRY_OFFSET = 6
  DIAGONAL_SPEED = Math.sqrt(2) / 2
  CARRY_SPEED = 0.6

  def initialize(options = {})
    options = {
    }.merge! options

    @carrying = nil

    super(options)

    on_input(:space, :action)
  end

  def effective_speed
    @carrying ? (@speed * CARRY_SPEED) : @speed
  end

  def update
    old_pos = [x, y]

    # Move the character.
    if holding_any? :left, :a
      self.factor_x = -1
      @carrying.factor_x = -1 if @carrying

      if holding_any? :up, :w
        self.x -= effective_speed * DIAGONAL_SPEED
        self.y -= effective_speed * DIAGONAL_SPEED
      elsif holding_any? :down, :s
        self.x -= effective_speed * DIAGONAL_SPEED
        self.y += effective_speed * DIAGONAL_SPEED
      else
        self.x -= effective_speed
      end
    elsif holding_any? :right, :d
      self.factor_x = 1
      @carrying.factor_x = 1 if @carrying

      if holding_any? :up, :w
        self.x += effective_speed * DIAGONAL_SPEED
        self.y -= effective_speed * DIAGONAL_SPEED
      elsif holding_any? :down, :s
        self.x += effective_speed * DIAGONAL_SPEED
        self.y += effective_speed * DIAGONAL_SPEED
      else
        self.x += effective_speed
      end
    elsif holding_any? :up, :w
      self.y -= effective_speed
    elsif holding_any? :down, :s
      self.y += effective_speed
    end

    # Keep co-ordinates inside the screen.
    self.x = [[x, $window.retro_width - (width / (2 * factor))].min, width / (2 * factor)].max
    self.y = [[y, $window.retro_height].min, height / factor].max

    if [x, y] != old_pos
      # broadcast our new position.
    end

    super
  end

  def action
    state = $window.current_game_state

    if @carrying
      # Drop whatever we are carrying.
      case @carrying
        when Mob
          if state.altar.ready? and distance_to(state.altar) <= ACTION_DISTANCE
            state.altar.sacrifice(self, @carrying)
          else
            state.mobs.push @carrying
            @carrying.drop(factor_x * 0.5, 0, 0.5)
          end

      end

      @carrying = nil
    else
      # Find the nearest goat and pick it up.
      nearest = state.mobs.min_by {|g| distance_to g }

      if nearest and distance_to(nearest) <= ACTION_DISTANCE
        @carrying = nearest
        @carrying.pick_up(self, CARRY_OFFSET)
        state.mobs.delete @carrying
      end
    end
  end
end
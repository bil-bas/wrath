require_relative 'player'

class LocalPlayer < Player
  ACTION_DISTANCE = 10
  CARRY_OFFSET = -6

  def initialize(options)
    options = {
    }.merge! options

    @carrying = nil

    super(options)

    on_input(:space, :action)
  end

  def update
    # Move the character.
    if holding_any? :left, :a
      if holding_any? :up, :w
        self.x -= @speed * 0.707
        self.y -= @speed * 0.707
      elsif holding_any? :down, :s
        self.x -= @speed * 0.707
        self.y += @speed * 0.707
      else
        self.x -= @speed
      end
    elsif holding_any? :right, :d
      if holding_any? :up, :w
        self.x += @speed * 0.707
        self.y -= @speed * 0.707
      elsif holding_any? :down, :s
        self.x += @speed * 0.707
        self.y += @speed * 0.707
      else
        self.x += @speed
      end
    elsif holding_any? :up, :w
      self.y -= @speed
    elsif holding_any? :down, :s
      self.y += @speed
    end

   # Keep co-ordinates inside the screen.
    self.x = [[x, ($window.width / $window.factor) - (width / (2 * factor))].min, width / (2 * factor)].max
    self.y = [[y, ($window.height / $window.factor)].min, height / factor].max
  end

  def action
    state = $window.current_game_state

    if @carrying
      # Drop whatever we are carrying.
      case @carrying
        when Goat
          if distance_to(state.altar) <= ACTION_DISTANCE
            # Goat disappears.
            @carrying.destroy
          else
            state.goats.push @carrying
            @carrying.y = y
          end

      end

      @carrying = nil
    else
      # Find the nearest goat and pick it up.
      nearest = state.goats.min_by {|g| distance_to g }

      if nearest and distance_to(nearest) <= ACTION_DISTANCE
        @carrying = nearest
        state.goats.delete @carrying
      end
    end
  end

  def draw
    super

    if @carrying
      @carrying.x, @carrying.y = x, y + CARRY_OFFSET
    end
  end
end
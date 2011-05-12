module Wrath
  # Humanoids are any sort of intelligent people. They move by "gliding" rather than bouncing.
  class Humanoid < Creature
    PORTRAIT_WIDTH = 7
    PORTRAIT_BACKGROUND_COLOR = Color.rgba(0, 0, 0, 100)
    PORTRAIT_CROP = [1, 0, 5, 4]
    PORTRAIT_PADDING = 1

    trait :timer

    def walking_to_do?; @walk_time_left > 0; end

    def initialize(options = {})
      options = {
          speed: 1,
          walk_duration: 2000,
          walk_interval: 2000,
      }.merge! options

      @walk_duration = options[:walk_duration]
      @walk_interval = options[:walk_interval]

      super(options)

      schedule_walk
    end

    def player=(player)
      super(player)

      if controlled_by_player?
        halt
      else
        schedule_walk
      end
    end

    def die!
      stop_timer(:walk)
      super
    end

    def schedule_walk
      @walk_time_left = 0

      return unless local? and not controlled_by_player?

      after(@walk_interval + (rand(@walk_interval / 2.0) + rand(@walk_interval / 2.0)), name: :walk) do
        walk
      end
    end

    def walk
      if state == :standing
          self.state = :walking
          self.facing = rand(360)
          @walk_time_left = @walk_duration
        elsif alive?
          schedule_walk
        end
    end

    def on_wounded
      # Try to move away from pain.
      if timer_exists? :walk
        stop_timer(:walk)
        walk
      end
    end

    def on_stopped
      schedule_walk

      super
    end

    def halt
      @walk_time_left = 0
      self.state = :standing
      schedule_walk
      super
    end

    def move(angle)
      self.state = :walking
      super(angle)
    end

    def update
      if local? and state == :walking and not controlled_by_player?
        if walking_to_do?
          @walk_time_left -= frame_time
          if walking_to_do?
            move(facing)
          else
            halt
          end
        else
          halt
        end
      end

      super
    end

    public
    def portrait
      unless @portrait
        @portrait = TexPlay.create_image($window, PORTRAIT_WIDTH, PORTRAIT_WIDTH, color: PORTRAIT_BACKGROUND_COLOR)
        @frames[0].refresh_cache
        @portrait.splice @frames[0], PORTRAIT_PADDING, PORTRAIT_PADDING, crop: PORTRAIT_CROP, alpha_blend: true
      end

      @portrait
    end

    public
    def on_collision(other)
      case other
        when Wall
          # Everything, except carrued objects, hit walls.
          collides = (not (can_pick_up? and inside_container?))

          # Bounce back from the edge of the screen
          if state == :walking and collides and not controlled_by_player?
            case other.side
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

          collides

        when StaticObject
          if state == :walking
            halt
            true
          else
            super
          end

        else
          super
      end
    end
  end
end
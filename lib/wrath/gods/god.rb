module Wrath
  class God < GameObject
    include Fidgit::Event
    include Log

    trait :timer

    attr_reader :anger

    BACKGROUND_COLOR = Color.rgba(0, 0, 0, 100)
    SAFE_COLOR = Color.rgb(0, 255, 255)
    DISASTER_COLOR = Color.rgb(255, 0, 255)
    ANGER_WIDTH = 30 # Of the bar.
    BORDER_WIDTH = 1
    PATIENCE_DURATION = 30 # 30s before first disaster.

    event :on_disaster_start
    event :on_disaster_end

    def in_disaster?; @in_disaster; end
    def anger=(value)
      @anger = [[value, @max_anger].min, 0].max

      if @in_disaster
        publish :on_disaster_end if @anger <= @max_safe_anger
      else
        publish :on_disaster_start if @anger >= @max_anger
      end

      @anger
    end

    def give_favor(amount)
      self.anger -= amount * @max_anger / 100.0
    end

    def initialize(options = {})
      options = {
          x: $window.retro_width / 2,
          y: 1,
          zorder: ZOrder::GUI,
          rotation_center: :top_center,
      }.merge! options

      super options

      @max_anger = PATIENCE_DURATION # Time before the god goes crazy (game ends).
      @max_safe_anger = @max_anger / 2
      @anger = 0

      @animation_cache ||= {}
      sprite_name = self.class.name.downcase[/[a-z]+$/]
      @animation_cache[options[:animation]] ||= Animation.new(file: "gods/#{sprite_name}_8x8.png", delay: 500)
      @frames = @animation_cache[options[:animation]]
      self.image = @frames[0]
      @animation_index = nil

      @anger_bar = Bar.create(x: x - ANGER_WIDTH / 2, y: y + image.height, width: ANGER_WIDTH, height: 4, value: 0.5, color: SAFE_COLOR)

      @num_disasters = 0
      @in_disaster = false

      subscribe(:on_disaster_start) { disaster_start }
      subscribe(:on_disaster_end) { disaster_end }
    end

    def update
      unless parent.client?
        old_anger = anger
        self.anger = anger + parent.frame_time / (@in_disaster ?  -250.0 : 1000.0)

        parent.send_message(Message::SetAnger.new(self)) if old_anger != anger and parent.host?
      end

      @anger_bar.color = @in_disaster ? DISASTER_COLOR : SAFE_COLOR

      @anger_bar.value = @anger / @max_anger
      # Give increasingly angry portrait when becoming angry. Keep max angry while in disaster.
      new_animation_index = in_disaster? ? 4 : (@anger_bar.value * 4).floor
      if new_animation_index != @animation_index
        @animation_index = new_animation_index
        frame_index = @animation_index * 2
        @current_animation = @frames[frame_index..(frame_index + 1)]
      end

      self.image = @current_animation.next

      super
    end

    def draw
      $window.pixel.draw x - BORDER_WIDTH - image.width / 2, y - BORDER_WIDTH, zorder, 10, 9, BACKGROUND_COLOR
      super
    end

    def disaster_start
      @num_disasters += 1
      @in_disaster = true
    end

    def disaster_end
      @in_disaster = false
    end

    def spawn_position(height)
      margin = parent.class::Margin
      [
        margin::LEFT + rand($window.retro_width - margin::LEFT - margin::RIGHT),
        margin::TOP + rand($window.retro_height - margin::TOP - margin::BOTTOM),
        height
      ]
    end
  end
end
module Wrath
  class God < GameObject
    include Fidgit::Event
    include Log

    trait :timer

    attr_reader :anger

    BACKGROUND_COLOR = Player::BACKGROUND_COLOR
    SAFE_COLOR = Color.rgb(0, 255, 255)
    DISASTER_COLOR = Color.rgb(255, 0, 255)
    ANGER_WIDTH = 30 # Of the bar.
    BORDER_WIDTH = 1
    PATIENCE_DURATION = 30 # 30s before first disaster.

    ANOINTED_MULTIPLIER = 1.5
    LOVE_MULTIPLIER = 1.5 # Favour multiplier for loved type.
    UNLOVED_MODIFIER = 0.25 # Favour multiplier for anything not loved.

    HAPPY_MUSIC = "No_Map.ogg"
    ANGRY_MUSIC = "Turn_For_The_Worst.ogg"

    event :on_disaster_start
    event :on_disaster_end

    def self.t; R18n.get.t.god[Inflector.underscore(Inflector.demodulize(name))]; end
    def t; self.class.t; end

    def self.to_s; t.name; end

    # Whether you can pick gods separate to levels.
    def self.unlocked_picking?; $window.achievement_manager.unlocked?(:general, :choose_god); end
    def self.icon; Image["gods/#{name[/[^:]+$/].downcase}_portrait.png"]; end


    def loves?(object)
      object.class == @loves
    end

    def loves=(loves)
      @loves = loves
      @loves_object.image = @loves.default_image if @loves

      parent.send_message(Message::GodLoves.new(@loves)) if parent.host?
      @loves
    end

    def favor_for(object)
      favor = object.base_favor
      if object.is_a? Creature
        favor *= ANOINTED_MULTIPLIER if object.anointed?
        favor *= (object.class == @loves) ? LOVE_MULTIPLIER : UNLOVED_MODIFIER
      end
      favor
    end

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

    # A player has gained favor, so appeasing the god.
    def give_favor(amount)
      self.anger -= amount * @max_anger / 100.0
    end

    def initialize(options = {})
      options = {
          x: $window.width / 2,
          y: 1,
          zorder: ZOrder::GUI,
          rotation_center: :top_center,
      }.merge! options

      super options

      @max_anger = PATIENCE_DURATION # Time before the god goes crazy (game ends).
      @max_safe_anger = @max_anger / 2
      @anger = @old_anger = 0

      @animation_cache ||= {}
      sprite_name = self.class.name.downcase[/[a-z]+$/]
      @animation_cache[options[:animation]] ||= Animation.new(file: "gods/#{sprite_name}_8x8.png", delay: 500)
      @frames = @animation_cache[options[:animation]]
      self.image = @frames[0]
      @animation_index = nil

      @anger_bar = Bar.new(x: x - ANGER_WIDTH / 2, y: y + image.height + BORDER_WIDTH, width: ANGER_WIDTH, color: SAFE_COLOR)

      @num_disasters = 0
      @in_disaster = false

      # The object that the god really wants!
      @loves_object = GameObject.new(x: x + (width / 2) + (ANGER_WIDTH - width) / 4, y: y + height - 1,
                                     zorder: ZOrder::GUI, rotation_center: :bottom_center, factor: 0.7)
      change_loved

      @happy_music = Song[HAPPY_MUSIC]
      @angry_music = Song[ANGRY_MUSIC]
      restart_music

      subscribe(:on_disaster_start) { disaster_start }
      subscribe(:on_disaster_end) { disaster_end }
    end

    def change_loved
      old_loves = @loves
      @loves = nil

      unless parent.client?
        after(1000) do
          self.loves = (parent.spawner.spawnable_objects - [old_loves]).select {|o| o.default_image }.sample
        end
      end
    end

    def update
      unless parent.client?
        self.anger = anger + parent.frame_time / (@in_disaster ?  -250.0 : 1000.0)
        parent.send_message(Message::SetAnger.new(self)) if @old_anger != anger and parent.host?
        @old_anger = anger
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
      $window.pixel.draw x - @anger_bar.width / 2 - BORDER_WIDTH , y - BORDER_WIDTH, zorder,
                         @anger_bar.width + BORDER_WIDTH * 2, height + @anger_bar.height + BORDER_WIDTH * 3,
                         BACKGROUND_COLOR

      @loves_object.draw if @loves
      @anger_bar.draw

      super
    end

    def disaster_start
      @num_disasters += 1
      @in_disaster = true

      restart_music
    end

    def disaster_end
      change_loved
      @in_disaster = false

      restart_music
    end

    def spawn_position(height)
      margin = parent.class::Margin
      [
        margin::LEFT + rand($window.width - margin::LEFT - margin::RIGHT),
        margin::TOP + rand($window.height - margin::TOP - margin::BOTTOM),
        height
      ]
    end

    def restart_music
      stop_music
      start_music
    end

    def start_music
      stop_music
      if @in_disaster
        @angry_music.play(true)
      else
        @happy_music.play(true)
      end
    end

    def stop_music
      @happy_music.pause
      @angry_music.pause
    end
  end
end
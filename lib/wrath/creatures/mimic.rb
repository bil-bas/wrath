module Wrath
  class Mimic < Mob

    DAMAGE = 5  / 1000.0 # 5/second
    FRAME_DISCOVERED = 0
    FRAME_UNDISCOVERED = 1

    def discovered?; @discovered; end
    def can_pick_up?; discovered?; end
    def can_be_activated?(actor); actor.empty_handed?; end

    def initialize(options = {})
      options = {
        favor: 10,
        health: 30,
        vertical_jump: 0.3,
        horizontal_jump: 0.6,
        elasticity: 0.4,
        jump_delay: 1000,
        encumbrance: 0.4,
        z_offset: -2,
        discovered: false,
        animation: "mimic_8x8.png",
      }.merge! options

      @discovered = options[:discovered]

      super(options)

      # Make the mimic seem innocuous.
      unless discovered?
        self.image = @walking_animation[FRAME_UNDISCOVERED]
        stop_timer(:jump)
      end
    end

    def recreate_options
      super.merge! discovered: @discovered
    end

    def activated_by(actor)
      if discovered?
        super(actor) # Just pick up.
      else
        wake_up
      end
    end

    def health=(value)
      super(value)
      wake_up unless discovered?
    end

    def wake_up
      Sample["chest_close.wav"].play

      parent.send_message(Message::PerformAction.new(self, self)) if parent.host?

      self.z_velocity = 0.5
      self.image = @walking_animation[FRAME_DISCOVERED]

      @discovered = true
      schedule_jump
    end

    def update
      super
      self.image = @walking_animation[FRAME_UNDISCOVERED] unless discovered?
    end

    def on_collision(other)
      return unless discovered?

      case other
        when Mimic
          # Do nothing.

        when Creature
          other.health -= DAMAGE * frame_time
      end

      super(other)
    end
  end
end
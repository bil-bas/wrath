module Wrath
  class Mimic < Animal
    FRAME_DISCOVERED = 0
    FRAME_UNDISCOVERED = 1

    DAMAGE = 10

    def hurts?(other); discovered? and not other.is_a?(Mimic); end
    def discovered?; @discovered; end
    def can_be_activated?(actor); actor.empty_handed?; end
    def dazed_offset_x; width * 0.125; end

    def initialize(options = {})
      options = {
        damage_per_hit: DAMAGE,
        favor: 10,
        health: 30,
        vertical_jump: 0.6,
        speed: 1.2,
        elasticity: 0.1,
        move_interval: 1000,
        move_type: :none, # Doesn't move until it is awakened.
        encumbrance: 0.4,
        z_offset: -2,
        animation: "mimic_8x8.png",
      }.merge! options

      super(options)

      # Make the mimic seem innocuous.
      @discovered = false
    end

    def recreate_options
      super.merge! discovered: @discovered
    end

    def draw_loved
      # Don't give away the fact that we are a mimic if no-one knows yet!
      super if discovered?
    end

    def activated_by(actor)
      if discovered?
        super(actor) # Just pick up.
      else
        wake_up
      end
    end

    def on_wounded(sender, damage)
      wake_up unless discovered?
    end

    def wake_up
      Sample["objects/chest_close.ogg"].play_at_x(x)

      parent.send_message(Message::PerformAction.new(self, self)) if parent.host?

      self.z_velocity = 0.5
      self.image = @walking_animation[FRAME_DISCOVERED]
      @discovered = true

      self.move_type = :jump
      schedule_move
    end

    def update
      super
      self.image = @walking_animation[FRAME_UNDISCOVERED] unless discovered?
    end
  end
end
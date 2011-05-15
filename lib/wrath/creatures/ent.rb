module Wrath
  class Ent < Humanoid
    DAMAGE = 10 / 1000.0 # damage/second
    MIN_PICKUP_DELAY = 1000
    DROP_AFTER = 250
    MIN_ENCUMBRANCE_TO_PICK_UP = 0.4

    trait :timer

    def can_be_picked_up?(container); false; end

    def initialize(options = {})
      options = {
        favor: 0,
        health: 1000000,
        walk_interval: 100,
        elasticity: 0,
        encumbrance: Float::INFINITY,
        damage: DAMAGE,
        animation: "ent_16x16.png",
        duration: 5000 + rand(2000),
      }.merge! options

      @damage = options[:damage]
      super options

      @last_picked_up_at = milliseconds
      @last_picked_up = nil

      after(options[:duration]) { go_to_sleep } if local?
    end

    def go_to_sleep
      Tree.create(position: position, can_wake: true) unless parent.client?
      self.destroy
    end

    def on_collision(other)
      if local? and other.is_a? Creature
        if empty_handed? and
            ((milliseconds - @last_picked_up_at) > MIN_PICKUP_DELAY) and
            (other.encumbrance >= MIN_ENCUMBRANCE_TO_PICK_UP) and
            (not other.thrown_by.include?(self)) and
            other.can_be_picked_up?(self) and
            @last_picked_up != other

          @last_picked_up_at = milliseconds
          @last_picked_up = other
          pick_up(other)
          after(DROP_AFTER) { drop if contents == other and parent }
          return false
        end

        unless other.is_a? Ent
          other.health -= @damage * parent.frame_time
        end
      end

      super(other)
    end
  end
end
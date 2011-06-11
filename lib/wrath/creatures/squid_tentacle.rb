module Wrath
  class SquidTentacle < Animal
    DAMAGE = 30
    DAMAGE_TO_HURT = 50

    def hurts?(other); not other.is_a?(self.class); end
    def can_be_picked_up?(container); false; end
    def stand_up_delay; 0; end
    def leave; @leaving = true; end

    def initialize(options = {})
      options = {
          flying_height: 4,
          damage_per_hit: DAMAGE,
          health: 100000,
          move_interval: 0,
          elasticity: 0,
          move_type: :walk,
          walk_duration: 3000,
          speed: 0.6,
          factor_y: 1.5,
          animation: "squid_tentacle_32x128.png",
      }.merge! options

      @leaving = false

      super options
    end

    def on_wounded(sender, amount)
      if health < max_health - DAMAGE_TO_HURT and !@leaving
        # TODO: blood splash.
        @leaving = true
      end
    end

    def update
      return unless exists?

      destroy if parent.host? and z > $window.height

      self.z_velocity = if @leaving
                          3
                        elsif z_velocity < 0
                          -2
                        else
                          0
                        end

      super
    end
  end
end
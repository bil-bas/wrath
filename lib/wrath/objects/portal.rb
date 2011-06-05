module Wrath
  class Portal < Container
    COLOR_1 = Color.rgb(255, 0, 0)
    COLOR_2 = Color.rgb(0, 200, 255)
    ANIMATION_INTERVAL = 250
    GROUND_ANIM = 0..1
    CARRIED_ANIM = 2..3
    MIN_EJECT_SPEED = 0.75
    EJECT_UP_SPEED = 1

    trait :timer

    def zorder; @on_ground ? ZOrder::TILES : super; end
    attr_accessor :partner
    def partnered?; partner and partner.exists?; end

    def initialize(options = {})
      options = {
          casts_shadow: false,
          favor: 0,
          z_offset: -2,
          elasticity: 0,
          #hide_contents: true,
          animation: "portal_8x12.png",
          color: self.class.all.empty? ? COLOR_1 : COLOR_2,
      }.merge! options

      unless self.class.all.empty?
        other = self.class.all.first
        @partner =  other
        other.partner = self
      end

      super(options)

      every(ANIMATION_INTERVAL) { animate }

      on_stopped
    end

    def animate
      self.image = @current_animation.next
    end

    def on_being_picked_up(other)
      @current_animation = @frames[CARRIED_ANIM]
      animate
      @on_ground = false
      self.rotation_center = :bottom_center
      super
    end

    def on_stopped
      @current_animation = @frames[GROUND_ANIM]
      animate
      @on_ground = true
      self.rotation_center =  :center_center
      super
    end

    def teleport(other)
      stored_velocity_x, stored_velocity_y = other.x_velocity, other.y_velocity

      # Throw looping objects or those moving too slowly out in a random direction.
      if other.thrown_by.include?(partner) or Math::sqrt(stored_velocity_x ** 2 + stored_velocity_y ** 2) < MIN_EJECT_SPEED
        direction = rand(360)
        speed = MIN_EJECT_SPEED
        stored_velocity_x = offset_x(direction, speed)
        stored_velocity_y = offset_y(direction, speed)
      end

      other.position = position
      other.velocity = [stored_velocity_x, stored_velocity_y, EJECT_UP_SPEED]

      Sample["objects/teleport.ogg"].play
    end

    def on_collision(other)
      case other
        when DynamicObject
          if other == partner
            self.position = parent.next_spawn_position(self) if thrown?
            on_stopped

          elsif container.nil? and not other.thrown_by.include?(self) and
              not thrown_by.include?(other) and
              other.z <= 0 and partnered?

            partner.pick_up(other)
            partner.drop

            if other.local?
              partner.teleport(other)
            else
              parent.send_message(Message::Teleport.new(other, partner))
            end
          end
      end

      super
    end
  end
end
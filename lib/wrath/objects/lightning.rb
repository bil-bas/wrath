module Wrath
  class Lightning < DynamicObject
    trait :timer

    ANIMATION_DELAY = 50
    DAMAGE = 20  / 1000.0 # 5/second
    GLOW_COLOR = Color.rgb(200, 200, 255)

    def can_be_picked_up?(actor); false; end

    def initialize(options = {})
      options = {
        animation: "lightning_8x128.png",
        casts_shadow: false,
      }.merge! options

      super options

      Sample["objects/rock_sacrifice.ogg"].play
      @frames.delay = ANIMATION_DELAY

      unless parent.client?
        after(100 + rand(200)) do
          Fire.create(position: position, parent: parent)
          destroy
        end
      end
    end

    def on_collision(other)
      case other
        when Creature
          other.health -= DAMAGE * frame_time
      end

      super(other)
    end

    def update
      super

      self.image = @frames.next
    end

    def draw
      super

      intensity = 3
      GLOW_COLOR.alpha = (40 * intensity).to_i
      parent.draw_glow(x, y, GLOW_COLOR, intensity)
    end
  end
end
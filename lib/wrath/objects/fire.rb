module Wrath
class Fire < DynamicObject
  trait :timer

  ANIMATION_DELAY = 500
  DAMAGE = 5  / 1000.0 # 5/second
  GLOW_COLOR = Color.rgb(255, 255, 50)

  trait :timer

  # To change this template use File | Settings | File Templates.

  def initialize(options = {})
    options = {
      favor: 2,
      encumbrance: -0.5,
      elasticity: 0.2,
      z_offset: -2,
      animation: "fire_8x8.png",
      casts_shadow: false,
    }.merge! options

    super options

    @frames.delay = ANIMATION_DELAY
  end

  def update
    super

    self.image = @frames.next
    if rand(100) < 3
      Smoke.create(x: x - 3 + rand(4) + rand(4), y: y - z - 3 - rand(3), zorder: y - 0.01 + rand(0.02))
    end
  end

  def on_collision(other)
    case other
      when Creature
        other.health -= DAMAGE * frame_time
    end

    super(other)
  end

  def draw
    super

    intensity = [1.5 - (z * 0.05), 0].max
    GLOW_COLOR.alpha = (40 * intensity).to_i
    parent.draw_glow(x, y, GLOW_COLOR, intensity)
  end
end
end
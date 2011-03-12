class Fire < Carriable
  trait :timer

  ANIMATION_DELAY = 300
  BURN_DAMAGE = 5  / 1000.0 # 5/second

  trait :timer

  # To change this template use File | Settings | File Templates.

  def initialize(options = {})
    options = {
      favor: 1,
      encumbrance: -0.5,
      elasticity: 0.2,
      z_offset: -2,
      animation: "fire_8x8.png",
    }.merge! options

    super options

    @frames.delay = ANIMATION_DELAY
  end

  def update
    super

    self.image = @frames.next
    if rand(100) < 10
      Smoke.create(local: false, id: -1, x: x - 3 + rand(4) + rand(4), y: y - z - 3 - rand(3), zorder: y - 0.01 + rand(0.02))
    end
  end
end
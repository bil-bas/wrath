module Wrath

class Knight < Humanoid
  DAMAGE = 5  / 1000.0 # 5/second

  def initialize(options = {})
    options = {
      favor: 30,
      health: 40,
      elasticity: 0.1,
      encumbrance: 0.5,
      z_offset: -2,
      damage: DAMAGE,
      animation: "knight_8x8.png",
    }.merge! options

    @damage = options[:damage]

    super options
  end

  def on_collision(other)
    case other
      when Priest
        other.health -= @damage * frame_time
    end

    super(other)
  end
end

end
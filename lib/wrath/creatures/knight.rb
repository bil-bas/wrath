# encoding: utf-8

class Knight < Mob
  DAMAGE = 5  / 1000.0 # 5/second

  def initialize(options = {})
    options = {
      favor: 30,
      vertical_jump: 0.2,
      horizontal_jump: 1.2,
      elasticity: 0.4,
      jump_delay: 800,
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
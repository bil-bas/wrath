class Wall < BasicGameObject
  ELASTICITY = 0
  FRICTION = 0

  attr_reader :side, :owner

  def initialize(x1, y1, x2, y2, side)
    super()

    @side = side

    body = CP::Body.new(Float::INFINITY, Float::INFINITY)

    @shape = CP::Shape::Segment.new(body, CP::Vec2.new(x1, y1), CP::Vec2.new(x2, y2), 0.0)
    @shape.e = ELASTICITY
    @shape.u = FRICTION
    @shape.body.p = CP::Vec2.new(0, 0)
    @shape.collision_type = :wall
    @shape.owner = self

    @parent.space.add_shape @shape # Body not needed, since we don't want to be affected by gravity et al.
  end
end
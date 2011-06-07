module Wrath
class Wall < BasicGameObject
  ELASTICITY = 0
  FRICTION = 0

  attr_reader :side, :owner

  def exists?; true; end

  def initialize(x1, y1, x2, y2, side)
    super()

    @side = side

       # vertices = [CP::Vec2.new(-width / 2, -depth), CP::Vec2.new(-width / 2, depth),
       #             CP::Vec2.new(width / 2, depth), CP::Vec2.new(width / 2, -depth)]
    @@body ||= CP::StaticBody.new # Can share a body quite happily.
    vertices = [CP::Vec2.new(x1, y1), CP::Vec2.new(x1, y2), CP::Vec2.new(x2, y2), CP::Vec2.new(x2, y1)]
    @shape = CP::Shape::Poly.new(@@body, vertices, CP::Vec2.new(0, 0))
    @shape.e = ELASTICITY
    @shape.u = FRICTION
    @shape.collision_type = :wall
    @shape.object = self

    @parent.space.add_shape @shape # Body not needed, since we don't want to be affected by gravity et al.
  end
end
end
module Wrath
  # A danger zone that discourages creatures from entering.
  class DangerZone < BasicGameObject
    VISUAL_RANGE = 8 # Consider this the visual range of creatures, to notice the danger.

    def initialize(object, body, shape_name, radius, space, options = {})
      super options

      radius += VISUAL_RANGE

      @shape = case shape_name
                  when :rectangle, CP::Shape::Poly
                    vertices = [vec2(-radius, -radius), vec2(-radius, radius),
                                vec2(radius, radius), vec2(radius, -radius)]
                    CP::Shape::Poly.new(body, vertices, vec2(0,0))
                  when :circle, CP::Shape::Circle
                    CP::Shape::Circle.new(body, radius, vec2(0,0))
                  else
                    raise "Bad shape #{shape_name}"
                end

      @shape.sensor = true
      @shape.collision_type = :danger
      @shape.group = CollisionGroup::DANGER
      @shape.object = object

      @space = space

      @space.add_shape @shape
    end

    def destroy
      @space.remove_shape @shape
    end
  end
end
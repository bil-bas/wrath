class Tree < StaticObject
  def initialize(options = {})
    options = {
      factor: 1.5,
      shape: :circle,
      animation: "tree_8x8.png",
      collision_type: :static
    }.merge! options

    super options

    @body.mass = Float::INFINITY
    parent.space.remove_body @body
  end
end
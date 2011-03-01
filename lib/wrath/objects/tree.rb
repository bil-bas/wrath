class Tree < StaticObject
  def initialize(options = {})
    options = {
      factor: 1.5,
      animation: "tree_8x8.png",
    }.merge! options

    super options
  end
end
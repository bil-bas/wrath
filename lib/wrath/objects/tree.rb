module Wrath
class Tree < StaticObject
  def can_wake?; @can_wake; end # Can wake to become an ent.

  def initialize(options = {})
    options = {
      shape: :circle,
      animation: "tree_12x12.png",
      can_wake: false,
    }.merge! options

    @can_wake = options[:can_wake]
    super options
  end
end
end
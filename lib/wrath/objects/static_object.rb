# encoding: utf-8

class StaticObject < WrathObject
  def can_be_activated?(object); false; end

  def initialize(options = {})
    options = {
      collision_type: :static,
      mass: Float::INFINITY,
    }.merge! options

    super options
  end
end
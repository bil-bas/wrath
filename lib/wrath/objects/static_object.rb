module Wrath

# An object that is immobile and blocks other objects from moving through it.
class StaticObject < BaseObject
  def network_sync?; false; end
  def can_be_activated?(object); false; end

  def initialize(options = {})
    options = {
      collision_type: :static,
      mass: Float::INFINITY,
    }.merge! options

    super options
  end
end
end
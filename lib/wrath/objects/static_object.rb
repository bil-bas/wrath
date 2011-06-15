module Wrath

# An object that is immobile and blocks other objects from moving through it.
class StaticObject < BaseObject
  def network_sync?; false; end
  def can_be_activated?(object); false; end

  def initialize(options = {})
    options = {
      collision_type: :static,
      mass: Float::INFINITY,
      paused: true,
    }.merge! options

    super options

    parent.objects << self if options[:interactive]
  end
end
end
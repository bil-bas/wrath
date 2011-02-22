require_relative 'static_object'

class Pebble < StaticObject
  trait :timer

  def initialize(options = {})
    options = {
      animation: "pebble_2x2.png",
    }.merge! options

    super options
  end
end
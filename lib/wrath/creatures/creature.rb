# encoding: utf-8

require_relative '../objects/wrath_object'

class Creature < WrathObject
  IMAGE_WALK1 = 0
  IMAGE_WALK2 = 1
  IMAGE_LIE = 2
  IMAGE_SLEEP = 3

  def initialize(options = {})
    options = {
    }.merge! options

    super options
  end
end
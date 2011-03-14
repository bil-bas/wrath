module Wrath
class Corpse < Carriable
  def initialize(options = {})
    options = {
        favor: 1,
        elasticity: 0,
    }.merge! options

    @sacrificial_explosion = options[:emitter]

    super(options)
  end
end
end
require_relative 'static_object'
require_relative '../carriable'

class Rock < StaticObject
  include Carriable

  IMAGE_POS = [[0, 0], [1, 0]]

  def initialize(options = {})
    options = {
      encumbrance: 0.6,
    }.merge! options

    super IMAGE_POS[rand(IMAGE_POS.size)], options
  end

end
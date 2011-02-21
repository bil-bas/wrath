require_relative '../carriable'

class Rock < WrathObject
  include Carriable

  def initialize(options = {})
    options = {
      image: $window.furniture_sprites[[3, 4][rand 2], 3],
      encumbrance: 0.6,
    }.merge! options

    super options
  end

end
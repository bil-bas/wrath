module Wrath
  class Boulder < StaticObject
    def initialize(options = {})
      options = {
        factor_x: 1.5,
        factor_y: 2,
        shape: :circle,
        animation: "rock_6x6.png"
      }.merge! options

      super options
    end
  end
end
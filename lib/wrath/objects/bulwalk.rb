module Wrath
  class Bulwalk < StaticObject
    def initialize(options = {})
      options = {
        animation: "bulwalk_8x6.png",
        shape: :rectangle,
        casts_shadow: false,
      }.merge! options

      super options
    end
  end
end
module Wrath
  class MoonRock < Rock
    COLOR = Color.rgb(0, 0, 255)

    def initialize(options = {})
      options = {
          color: COLOR
      }.merge! options

      super(options)
    end
  end
end
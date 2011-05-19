module Wrath
  class Boulder < StaticObject
    def initialize(options = {})
      options = {
        shape: :circle,
        animation: "boulder_9x12.png",
      }.merge! options

      super options

      self.image = @frames.frames.sample
    end
  end
end
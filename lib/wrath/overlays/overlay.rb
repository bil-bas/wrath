module Wrath
  class Overlay < BasicGameObject
    include Log

    def initialize(options = {})
      options = {
          visible: false,
      }.merge! options

      @visible = options[:visible]

      super()
    end

    def visible?; @visible; end

    def toggle
      @visible = (not @visible)
    end
  end
end
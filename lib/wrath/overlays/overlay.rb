module Wrath
  class Overlay < BasicGameObject
    include Log

    def initialize
      @visible = false
    end

    def visible?; @visible; end

    def toggle
      @visible = (not @visible)
    end
  end
end
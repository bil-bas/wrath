module Wrath
  class Block < StaticObject
    SPRITES = {
        1 => "10x10",
        2 => "10x18",
        3 => "10x26",
    }
    def initialize(options = {})
      options = {
        factor_x: 1, # All should be aligned identically.
      }.merge! options

      @stack = options[:stack]
      options[:animation] ||= "block_#{SPRITES[@stack]}.png"

      super options
    end

  def recreate_options
    {
        stack: @stack,
    }.merge! super
  end
  end
end
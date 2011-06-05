module Wrath
  # Animals are any sort of non-intelligent creatures.
  class Animal < Creature

    def dazed_offset_x; width * 0.25; end

    def initialize(options = {})
      options = {
          move_type: :jump,
      }.merge! options
      super(options)
    end
  end
end
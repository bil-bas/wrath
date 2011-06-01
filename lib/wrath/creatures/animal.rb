module Wrath
  # Animals are any sort of non-intelligent creatures.
  class Animal < Creature
    def initialize(options = {})
      options = {
          move_type: :jump,
      }.merge! options
      super(options)
    end
  end
end
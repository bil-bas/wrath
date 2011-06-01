module Wrath
  class TestSubject < Humanoid
    public
    def initialize(options = {})
      options = {
          favor: 10,
          move_type: :jump,
          vertical_jump: 2,
          horizontal_jump: 1.5,
          elasticity: 0.8,
          animation: "test_subject_8x8.png",
      }.merge! options

      super options
    end
  end
end
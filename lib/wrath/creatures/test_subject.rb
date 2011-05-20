module Wrath
  class TestSubject < Humanoid
    public
    def initialize(options = {})
      options = {
        favor: 10,
        health: 30,
        encumbrance: 0.4,
        z_offset: -2,
        animation: "test_subject_8x8.png",
      }.merge! options

      super options
    end
  end
end
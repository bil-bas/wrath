module Wrath
  class Monkey < Mob
    def initialize(options = {})
      options = {
        favor: 15,
        health: 20,
        vertical_jump: 0.5,
        horizontal_jump: 0.2,
        elasticity: 0.5,
        jump_delay: 500,
        encumbrance: 0.7, # To simulate covering your eyes.
        z_offset: -3,
        animation: "monkey_8x8.png",
      }.merge! options

      super(options)
    end
  end
end
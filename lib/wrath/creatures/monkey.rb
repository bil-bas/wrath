module Wrath
  class Monkey < Animal
    def can_knock_down_creature?(creature); false; end

    def initialize(options = {})
      options = {
          favor: 6,
          health: 20,
          vertical_jump: 1.2,
          speed: 1,
          elasticity: 0.5,
          move_interval: 500,
          encumbrance: 0.7, # To simulate covering your eyes.
          z_offset: -3,
          animation: "monkey_8x8.png",
      }.merge! options

      super(options)
    end

    def on_collision(object)
      # Monkeys like to jump on your head.
      if object.is_a? Creature and not object.thrown? and object.controlled_by_player? and object.empty_handed? and
          object.alive? and not @thrown_by.include? object and not object.inside_container?

        # Can jump from one to another guy.
        if inside_container?
          container.drop
          @thrown_by << container # So it won't just jump back.
        end

        object.pick_up(self)
      end

      super
    end
  end
end
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

    def on_collision(other)
      case other
        when Portal
          if empty_handed? and [:standing, :walking].include?(state) and not other.thrown? and rand() < 0.5
            pick_up(other)
            stop_timer(:drop_portal)
            after(random(2000, 3000), name: :drop_portal) { drop unless empty_handed? }

            false
          else
            super
          end

        else
          super
      end
    end
  end
end
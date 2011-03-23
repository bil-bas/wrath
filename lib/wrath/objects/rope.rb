module Wrath
  class Rope < DynamicObject
    def initialize(options = {})
      options = {
          shape: :circle,
          radius: 6,
          z_offset: -2,
          animation: "rope_10x6.png",
      }.merge! options

      super(options)
    end

    def on_collision(other)
      case other
        when Priest, Virgin, Knight, Paladin, Bard
          if not thrown_by.include? other and (not inside_container?) and z > ground_level
            destroy
            other.pick_up(TiedRope.create(parent: parent))
          end
      end

      super(other)
    end
  end
end
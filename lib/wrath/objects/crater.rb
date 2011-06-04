module Wrath
  class Crater < StaticObject
    def zorder; ZOrder::TILES; end

    public
    def initialize(options = {})
      options = {
          animation: "crater_13x8.png",
          casts_shadow: false,
          rotation_center: :center_center,
          collision_type: :scenery,
          factor_x: 1,
      }.merge! options

      super options

    end
  end
end
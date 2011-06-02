module Wrath
  class X < Container
    def zorder; ZOrder::TILES; end

    public
    def initialize(options = {})
      options = {
          animation: "x_8x8.png",
          hide_contents: true,
          drop_velocity: [0, 0, 1.5],
          casts_shadow: false,
          scale: 0.7,
          rotation_center: :center_center,
      }.merge! options
      super options
    end

    def can_be_activated?(actor)
      actor.empty_handed?
    end

    def activated_by(actor)
      contents.position = self.position
      drop
      destroy
    end
  end
end
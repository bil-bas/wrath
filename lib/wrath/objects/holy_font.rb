module Wrath
  # A sacrifice can be empowered by first annointing it.
  class HolyFont < StaticObject

    def can_be_activated?(actor)
      object = actor.contents
      actor.carrying? and object.is_a? Creature and object.favor > 0 and not object.anointed?
    end
    def can_be_picked_up?(actor); false; end

    def initialize(options = {})
      options = {
          animation: "font_6x6.png",
          collision_shape: :circle,
          interactive: true,
      }.merge! options

      super options
    end

    def activated_by(actor)
      actor.contents.apply_status(:anointed)

      parent.send_message Message::PerformAction.new(actor, self) if parent.host?

      log.debug { "#{actor} anointed #{actor.contents}" }
    end
  end
end
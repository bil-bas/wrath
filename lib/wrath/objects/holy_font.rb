module Wrath
  # A sacrifice can be empowered by first annointing it.
  class HolyFont < StaticObject
    trait :timer

    SMOKE_COLOR = Color.rgba(50, 50, 255, 150)

    def can_be_activated?(actor)
      actor.carrying?
    end
    def can_be_picked_up?(actor); false; end

    def initialize(options = {})
      options = {
          animation: "font_6x6.png",
          collision_shape: :circle,
          interactive: true,
          paused: false,
      }.merge! options

      super options

      every(250) do
        Smoke.create(color: SMOKE_COLOR.dup, x: random(x - 2, x + 2), y: y - collision_height, zorder: y,
                     alpha_decay_speed: 0.025, factor: 1, mode: :additive)
      end
    end

    def activated_by(actor)
      parent.send_message Message::PerformAction.new(actor, self) if parent.host?

      object = actor.contents
      if object.is_a? Creature and object.favor > 0 and not object.anointed?
        object.apply_status(:anointed)

        Sample["objects/font_anoint.ogg"].play_at_x(x)

        log.debug { "#{actor} anointed #{object}" }
      else
        Sample["objects/font_anoint_fail.ogg"].play_at_x(x)

        log.debug { "#{actor} failed to anoint #{object}" }
      end
    end
  end
end
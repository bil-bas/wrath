module Wrath
  class Spark < Droplet
    SMOKE_COLOR = Color.rgba(50, 50, 50, 125) # Bit thicker than normal smoke.

    def on_stopped
      color = SMOKE_COLOR.dup
      color.alpha += rand(50)
      Smoke.create(x: x, y: y - z, color: color)
      destroy
    end
  end
end
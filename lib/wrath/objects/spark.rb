module Wrath
  class Spark < Droplet
    SMOKE_COLOR = Color.rgb(0, 0, 0)

    def on_stopped(sender)
      color = SMOKE_COLOR.dup
      color.alpha = random(50, 100).to_i
      Smoke.create(parent: parent, x: x, y: y - z, color: color)
      destroy
    end
  end
end
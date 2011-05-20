module Wrath
class BloodDroplet < Droplet
  COLOR = Color.rgb(255, 0, 0)

  def initialize(options = {})
    options = {
    }.merge! options

    options[:color] = COLOR.dup

    super options
  end
end
end
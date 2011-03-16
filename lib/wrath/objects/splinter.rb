module Wrath
class Splinter < Droplet
  COLOR = Color.rgb(73, 60, 43)

  def initialize(options = {})
    options = {
      color: COLOR,
    }.merge! options

    super options
  end
end
end
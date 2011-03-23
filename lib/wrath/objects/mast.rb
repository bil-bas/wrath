module Wrath
class Mast < StaticObject
  IMAGE_REPEATS = 20

  def initialize(options = {})
    options = {
      shape: :circle,
      animation: "mast_8x8.png"
    }.merge! options

    super options

    unless defined? @@mast_image
      @@mast_image = TexPlay.create_image($window, width, height * IMAGE_REPEATS)
      (0...(height * IMAGE_REPEATS)).step(height) do |y|
        @@mast_image.splice @frames[0], 0, y
      end
    end

    self.image = @@mast_image
  end
end
end

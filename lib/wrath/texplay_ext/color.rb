module Gosu
  class Color
    def self.from_texplay(array)
      rgba(*array.map {|c| (c * 255).to_i })
    end
  end
end
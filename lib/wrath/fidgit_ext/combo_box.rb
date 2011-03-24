module Fidgit
  class ComboBox
    def each
      @menu.instance_variable_get(:@items).each do |item|
        yield item
      end
    end
  end
end
module Fidgit
  class ComboBox
    def each
      @menu.instance_variable_get(:@items).each do |item|
        yield item
      end
    end

    def item(text, value, options = {}, &block)
      item = @menu.item(text, value, options, &block)

      # Force text to be updated if the item added has the same value.
      if item.value == @value
        self.text = item.text
        self.icon = item.icon
      end

      item
    end

    def clear
      self.text = ""
      self.icon = nil
      @menu.instance_variable_get(:@items).clear
    end
  end
end
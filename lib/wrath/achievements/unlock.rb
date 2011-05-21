module Wrath
  class Unlock
    attr_reader :name, :title, :type, :image

    def initialize(definition)
      @name = definition[:name]

      @type = definition[:type]

      case @type
        when :priest
          @image = Priest.icon(@name)
          @title = Priest.title(@name)

        when :level
          level = Level.const_get(@name)
          @image = level.icon
          @title = level.to_s

        else
          raise "Unknown unlock type: #{@type}"
      end
    end
  end
end
module Wrath
  class Unlock
    attr_reader :name, :description

    def initialize(definition)
      @name = definition[:name]
      @description = definition[:description]
    end
  end
end
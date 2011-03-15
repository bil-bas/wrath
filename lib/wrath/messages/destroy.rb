module Wrath
class Message
  class Destroy < Message
    def initialize(object)
      @id = object.id
    end

    def process
      object = object_by_id(@id)
      if object
        object.destroy
      else
        log.error { "#{self.class} failed to destroy object ##{@id}" }
      end
    end
  end
end
end
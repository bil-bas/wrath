module Wrath
class Message
  class Destroy < Message
    def initialize(object)
      @id = object.id
    end

    def process
      object = find_object_by_id(@id)
      if object
        object.destroy
      else
        log.error { "Failed to destroy object ##{@id}" }
      end
    end
  end
end
end
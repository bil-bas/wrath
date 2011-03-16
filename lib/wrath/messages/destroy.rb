module Wrath
class Message
  class Destroy < Message
    public
    def initialize(object)
      @id = object.id
    end

    protected
    def action(state)
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
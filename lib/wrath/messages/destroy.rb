class Message
  class Destroy < Message
    def initialize(object)
      @id = object.id
    end

    def process
      find_object_by_id(@id).destroy
    end
  end
end
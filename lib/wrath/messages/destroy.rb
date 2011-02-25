class Message
  class Destroy < Message
    value :id, nil

    def process
      find_object_by_id(id).destroy
    end
  end
end
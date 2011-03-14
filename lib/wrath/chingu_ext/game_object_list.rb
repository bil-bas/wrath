module Chingu
  class GameObjectList
    alias_method :original_initialize, :initialize
    def initialize(options = {})
      @objects_by_id = {}
      original_initialize(options)
    end

    alias_method :original_add_game_object, :add_game_object
    def add_game_object(object)
      @objects_by_id[object.id] = object if object.respond_to?(:id) and object.id >= 0
      original_add_game_object(object)
    end

    alias_method :original_remove_game_object, :remove_game_object
    def remove_game_object(object)
      @objects_by_id.delete object.id if object.respond_to?(:id)
      original_remove_game_object(object)
    end

    def object_by_id(id)
      @objects_by_id[id]
    end
  end
end
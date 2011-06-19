module Chingu
  class GameObjectList
    alias_method :original_initialize, :initialize
    def initialize(options = {})
      @objects_by_id = {}
      original_initialize(options)
    end

    alias_method :original_add_game_object, :add_game_object
    def add_game_object(object)
      @objects_by_id[object.id] = object if object.respond_to?(:id) and object.id
      original_add_game_object(object)
    end

    alias_method :original_remove_game_object, :remove_game_object
    def remove_game_object(object)
      @objects_by_id.delete object.id if object.respond_to?(:id) and object.id
      original_remove_game_object(object)
    end

    def object_by_id(id)
      @objects_by_id[id]
    end

    def update
      # Ensure you don't call update on objects that have already been destroyed.
      @unpaused_game_objects.each do |go|
        if go.is_a? Wrath::BaseObject
          if go.exists?
            go.update_trait
            go.update if go.exists?
          end
        else
          go.update_trait
          go.update
        end
      end
    end
  end
end
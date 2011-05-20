module Wrath
  # God of the forest.
  class Dryad < God
    def loved_objects; [Bard, Virgin, Knight, Goat]; end

    def disaster_duration; 0; end

    def on_disaster_start(sender)
      unless parent.client?
        Tree.all.select(&:can_wake?).sample(4).each do |tree|
          Ent.create(position: tree.position, parent: parent)
          tree.destroy
        end
      end
    end

    def on_disaster_end(sender)
      unless parent.client?
        Ent.all.each do |ent|
          ent.go_to_sleep
        end
      end
    end
  end
end
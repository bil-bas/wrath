module Wrath
  # God of the forest.
  class Dryad < God
    def disaster_duration; 0; end

    def on_disaster(sender)
      unless parent.client?
        Tree.all.select(&:can_wake?).sample(4).each do |tree|
          Ent.create(position: tree.position)
          tree.destroy
        end
      end
    end
  end
end
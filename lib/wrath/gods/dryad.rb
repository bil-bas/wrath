module Wrath
  # God of the forest.
  class Dryad < God
    NUM_ENTS = 4
    MIN_TREES = 6

    def disaster_duration; 0; end

    def on_disaster_start(sender)
      unless parent.client?
        # Create some trees if there aren't enough.
        (MIN_TREES - Tree.all.size).times.each do |tree|
          Tree.create(can_wake: true)
        end

        Tree.all.select(&:can_wake?).sample(NUM_ENTS).each do |tree|
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
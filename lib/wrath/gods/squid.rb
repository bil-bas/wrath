module Wrath
  class Squid < God
    def on_disaster_start(sender)
      SquidTentacle.create(position: spawn_position($window.height), parent: parent) unless parent.client?
    end

    def on_disaster_end(sender)
      SquidTentacle.all.each(&:leave) unless parent.client?
    end
  end
end
module Wrath
  class Squid < God
    def self.to_s; "The Kraken"; end

    def on_disaster_start(sender)
      SquidTentacle.create(position: spawn_position($window.retro_height), parent: parent) unless parent.client?
    end

    def on_disaster_end(sender)
      SquidTentacle.all.each(&:leave) unless parent.client?
    end
  end
end
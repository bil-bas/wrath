module Wrath
  class NetworkOverlay
    include Log

    MAX_HISTORY = 300
    SCALE = 1000.0
    SENT_COLOR = Color.rgba(0, 0, 255, 100)
    RECEIVED_COLOR = Color.rgba(0, 255, 0, 100)
    TEXT_COLOR = Color.rgba(255, 255, 255, 100)

    class Clock < BasicGameObject
      trait :timer
    end

    def initialize(network)
      @network = network
      @network.reset_counters

      @clock = Clock.new
      @clock.every(1000) { count }

      @visible = false
      @font = Font[15]

      @seconds = [] # Recorded values from each second.
    end

    def toggle
      @visible = (not @visible)
    end

    def average_over(time, y)
      time = [time, @seconds.size].min
      sent, received = 0, 0
      @seconds[-time..-1].each do |second|
        sent += second[:sent]
        received += second[:received]
      end

      str = "%7ds %12d %12d" % [time, (sent / time).round, (received / time).round]
      @font.draw str, 0, y, ZOrder::GUI, 1, 1, TEXT_COLOR
    end

    def draw
      if @visible
        @font.draw "Over(s)     Sent(b) Received(b)", 0, $window.height - 80, ZOrder::GUI, 1, 1, TEXT_COLOR

        unless @seconds.empty?
          average_over(1, $window.height - 60)
          average_over(10, $window.height - 40)
          average_over(60, $window.height - 20)

          pixel = $window.pixel
          @seconds.each_with_index do |data, i|
            sent_height, received_height = data[:sent] / SCALE, data[:received] / SCALE
            pixel.draw i, 200 - sent_height, ZOrder::GUI, 1, sent_height, SENT_COLOR
            pixel.draw i, 400 - received_height, ZOrder::GUI, 1, received_height, RECEIVED_COLOR
          end
        end
      end
    end

    def update
      @clock.update_trait
    end

    def count
      @seconds.shift if @seconds.size == MAX_HISTORY
      @seconds << { sent: @network.bytes_sent, received: @network.bytes_received }
      log.debug { "Over the last second, sent #{@network.bytes_sent} bytes in #{@network.packets_sent} packets; and received #{@network.bytes_received} bytes in #{@network.packets_received} packets" }
      @network.reset_counters
    end
  end
end
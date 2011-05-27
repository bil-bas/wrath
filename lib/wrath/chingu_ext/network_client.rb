module Chingu
  class NetworkClient
      #
      # Connect to a given ip:port (the server)
      # Connect is done in a blocking manner.
      # Will timeout after 4 seconds
      #
      def connect(ip = nil, port = nil)
        return if @socket

        @ip = ip      if ip
        @port = port  if port

        begin
          status = Timeout::timeout(@timeout) do
            @socket = TCPSocket.new(@ip, @port)
            on_connect
          end
        rescue Errno::ECONNREFUSED
          on_connection_refused
        rescue Timeout::Error
          on_timeout
        end

        return self
      end
  end
end
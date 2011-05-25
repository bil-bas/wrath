module Chingu
  module GameStates
    class NetworkServer < GameState    
      attr_reader :max_connections
      alias_method :address, :ip
    
      def initialize(options = {})
        options = {
          address: "0.0.0.0",
          port: DEFAULT_PORT,
          max_connections: 256, # Reasonable maximum!
          max_read_per_update: 20000,
        }.merge! options
        
        super
        
        @ip = options[:address]
        @port = options[:port]
        @debug = options[:debug]
        @max_connections = options[:max_connections] 
        @max_read_per_update = options[:max_read_per_update]
        
        @socket = nil
        @sockets = []

        @packet_buffers = Hash.new
      end
      
      #
      # Call this from your update() to read from socket.
      # handle_incoming_data will call on_data(raw_data) when stuff comes on on the socket.
      #
      def handle_incoming_data(max_size = @max_read_per_update)        
        @sockets.each do |socket|
          begin
            if IO.select([socket], nil, nil, 0.0)          
              packet, sender = socket.recvfrom(max_size)
              on_data(socket, packet)
            end   
          rescue Errno::ECONNABORTED, Errno::ECONNRESET, IOError
            disconnect_client(socket)
          end          
        end
      end
      
      # Ensure that the buffer is cleared of data to write (call at the end of update or, at least after all sends).
      def flush
        @sockets.each do |socket|
          begin
            socket.flush
          rescue IOError
            disconnect_client(socket)
          end
        end
      end
      
      #
      # Shuts down all communication (closes socket) with a specific socket
      #
      def disconnect_client(socket)
        socket.close
        @sockets.delete socket
        @packet_buffers.delete socket
        on_disconnect(socket)
      rescue Errno::ENOTCONN
      end
      
      def stop
        return unless @socket

        @sockets.each {|socket| disconnect_client(socket) }
        @sockets = []
        @socket.close
        @socket = nil
      rescue Errno::ENOTCONN
      end
      
      def handle_incoming_connections
        begin
          while socket = @socket.accept_nonblock
            if @sockets.size < @max_connections
              @sockets << socket
              @packet_buffers[socket] = PacketBuffer.new
              on_connect(socket)
            else
              socket.close
            end
          end
        rescue IO::WaitReadable, Errno::EINTR
        end
      end
    end
  end
end
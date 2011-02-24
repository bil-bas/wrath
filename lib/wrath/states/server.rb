# encoding: utf-8

Thread.abort_on_exception = true

class Server < GameStates::NetworkServer
  trait :timer

  attr_reader :remote_socket

  def initialize(options = {})
    options = {
      address: "0.0.0.0",
      port: 7778,
    }.merge! options

    @remote_socket = nil

    @send_queues = Hash.new
    @receive_queues = Hash.new

    @font = Font[16]

    super options

    on_input(:escape) { pop_game_state }

    start(options[:address], options[:port])
  end

  #
  # Called for each new client connecting to our server
  #
  def on_connect(socket)
    puts "* Player connected: #{socket.inspect}"
    @remote_socket = socket
  end

  def on_disconnect(socket)
    puts "* Player disconnected: #{socket.inspect}"
  end

  def handle_incoming_connections
    begin
      socket = @socket.accept_nonblock
      @sockets << socket
      on_connect(socket)

      send_queue, receive_queue = Queue.new, Queue.new
      @send_queues[socket] = send_queue
      @receive_queues[socket] = receive_queue

      Thread.new do
        loop do
          json = socket.gets
          #puts "received #{json}"
          receive_queue.push JSON.parse(json)
        end
      end

      Thread.new do
        loop do
          json = send_queue.pop
          #puts "sending #{json}"
          send_data socket, json
        end
      end

    rescue IO::WaitReadable, Errno::EINTR
    end
  end

  def handle_incoming_data
    @receive_queues.each_pair do |socket, queue|
      while not queue.empty?
        on_msg(socket, queue.pop)
      end
    end
  end

  def handle_outgoing_data

  end


  def draw
    @font.draw("Waiting for client...", 0, 0, ZOrder::GUI)
  end

  def on_msg(socket, message)
    message.process
  end

  def send_msg(socket, message)
    data = message.to_json
    @send_queues[socket].push data
  end

  def broadcast_msg(message)
    data = message.to_json
    @send_queues.each_value {|queue| queue.push data }
  end

  # Send whatever raw data to the server
  #
  def send_data(socket, data)
    socket.puts(data)
    socket.flush
  end

  def update
    if current_game_state.is_a? Play
      @@counter ||= 0
      @@counter += 1
      if @@counter % 4 == 0
        updates = 0
        current_game_state.objects.each do |object|
          if object.needs_status_update?
            updates += 1
            broadcast_msg(Message::Status.new(object.status))
          end
        end
        puts "Sent updates for #{updates} objects"
      end
    end

    super
  end
end
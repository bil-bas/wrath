Thread.abort_on_exception = true

class Client < GameStates::NetworkClient
  trait :timer

  def initialize(options = {})
    options = {
      ip: "127.0.0.1",
      port: 7778,
    }.merge! options

    @font = Font[16]

    @receive_queue = Queue.new
    @receive_thread = nil

    super options

    on_input(:escape) { disconnect; pop_game_state }

    after(0.1) { connect(options[:ip], options[:port]) }
  end

  def on_connect
    puts "Connected to server"
    push_game_state Play.new(self)
    send_msg(Message::Ready.new)
  end

  def on_disconnect
    puts "* Disconnected from server"
  end

  def draw
    @font.draw("Connecting...", 0, 0, ZOrder::GUI)
  end

  def update
    handle_incoming_data

    while not @receive_queue.empty?
      on_msg(@receive_queue.pop)
    end

    super
  end

  def connect(ip, port = 7778)
    return if @socket
    @ip = ip
    @port = port

    begin
      status = Timeout::timeout(@timeout) do
        @socket = TCPSocket.new(ip, port)
        on_connect
        @receive_thread = Thread.new(@socket) do |socket|
          loop do
            json = socket.gets
            #puts "received #{json}"
            @receive_queue.push JSON.parse(json)
          end
        end
      end
    rescue Errno::ECONNREFUSED
      on_connection_refused
    rescue Timeout
      on_timeout
    end
  end

  def send_msg(msg)
    data = msg.to_json
    send_data(data)
  end

  # Send whatever raw data to the server
  #
  def send_data(data)
    #puts "sending #{data}"
    @socket.puts(data)
    @socket.flush
  end

  def handle_incoming_data
    # Ensure we've cleared the buffer before we process.
    if @receive_thread and @receive_thread.status == "run"
      @receive_thread.wakeup
    end
  end

  def on_msg(message)
    message.process
  end
end
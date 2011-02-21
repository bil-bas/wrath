class RemotePlayer < Player
  attr_reader :socket

  def initialize(socket, options = {})
    options = {
        gui_pos: [100, 110]
    }.merge! options

    @socket = socket

    super options
  end
end
# encoding: utf-8

class RemotePlayer < Player
  attr_reader :socket

  def initialize(options = {})
    options = {
    }.merge! options

    super options
  end
end
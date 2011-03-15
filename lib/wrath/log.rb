module Wrath
  module Log
    class << self
      attr_accessor :log
    end

    def log; Log::log; end

    self.log = Logger.new(STDERR)
    log.level = Logger::DEBUG
    log.formatter = lambda do |type, time, progname, message|
      $stderr.puts "[#{time} #{type[0..0]}] #{progname ? "#{progname}: ": ''}#{message}"
    end

    log.info "Enabled logging at level #{log.level}"
  end
end




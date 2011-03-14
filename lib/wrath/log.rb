module Wrath
  def self.log_formatter(type, time, progname, message)
    $stderr.puts "[#{time} #{type[0..0]}] #{message}"
  end

  log.level = Logger::DEBUG
  log.formatter = method :log_formatter

  log.debug "Enabled debug messages"
  log.info "Enabled info messages"
  log.warn "Enabled warning messages"
  log.error "Enabled error messages"
  log.fatal "Enabled fatal messages"
end


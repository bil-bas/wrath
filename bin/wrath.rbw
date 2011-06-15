#!/usr/bin/env ruby

require 'optparse'

begin
  EXTRACT_PATH = File.dirname(File.dirname(File.expand_path(__FILE__)))

  ROOT_PATH = if ENV['OCRA_EXECUTABLE']
                File.dirname(File.expand_path(ENV['OCRA_EXECUTABLE']))
              elsif defined? OSX_EXECUTABLE_FOLDER
                File.dirname(OSX_EXECUTABLE_FOLDER)
              else
                EXTRACT_PATH
              end

  APP_NAME = File.basename(__FILE__).chomp(File.extname(__FILE__))

  RUNNING_FROM_EXECUTABLE = (ENV['OCRA_EXECUTABLE'] or defined?(OSX_EXECUTABLE))

  DEFAULT_LOG_FILE = "#{APP_NAME}.log"
  DEFAULT_LOG_FILE_PATH = File.join(ROOT_PATH, DEFAULT_LOG_FILE)

  def parse_options
    options = {}

    OptionParser.new do |parser|
      parser.banner =<<TEXT
Usage: #{File.basename(__FILE__)} [options]

  Defaults to using --#{RUNNING_FROM_EXECUTABLE ? 'log' : 'console'}

TEXT

      parser.on('-?', '-h', '--help', 'Display this screen') do
        puts parser
        exit
      end

      options[:dev] = false
      parser.on('--dev', 'Development mode') do
        options[:dev] = true
      end

      parser.on('--console', 'Console mode (no log file)') do
        options[:log] = nil # Write to console.
      end

      parser.on('--log [FILE]', "Write log to a file (defaults to '#{DEFAULT_LOG_FILE}')") do |file|
        options[:log] = file ? file : DEFAULT_LOG_FILE_PATH
      end

      parser.on('--timestamp', "Adds a timestamp to the log file") do
        options[:timestamp] = true
      end

      begin
        parser.parse!
      rescue OptionParser::ParseError => ex
        puts "ERROR: #{ex.message}"
        puts
        puts parser
        exit
      end
    end

    options
  end

  options = parse_options

  # Default to console mode normally; default to logfile when running executable.
  if RUNNING_FROM_EXECUTABLE and not options.has_key?(:log)
    options[:log] = DEFAULT_LOG_FILE_PATH
  end

  LOG_FILE = options[:log]
  DEVELOPMENT_MODE = options[:dev]

  ENV['PATH'] = "#{File.join(ROOT_PATH, 'bin')};#{ENV['PATH']}"

  if LOG_FILE
    # Add a timestamp to the end of the log file-name.
    if options[:timestamp]
      LOG_FILE.sub!(/(\.\w+)$/, "_#{Time.now.to_s.gsub(/[^\d]/, "_")}_#{Time.now.usec.to_s.rjust(6, '0')}\\1")
    end

    puts "Redirecting output to '#{LOG_FILE}'"

    original_stderr = $stderr.dup
    $stderr.reopen LOG_FILE
    $stderr.sync = true

    original_stdout = $stdout.dup
    $stdout.reopen LOG_FILE
    $stdout.sync = true
  end

  require_relative "../lib/#{APP_NAME}"

  app_module = Kernel::const_get(APP_NAME.split('_').map(&:capitalize).join.to_sym)
  exit_message = app_module::Game.run unless defined? Ocra

rescue => ex
  $stderr.puts "FATAL ERROR - #{ex.class}: #{ex.message}\n#{ex.backtrace.join("\n")}"
  raise ex # Just to make sure that the user sees the error in the CLI/IDE too.
ensure
  $stderr.reopen(original_stderr) if defined?(original_stderr) and original_stderr
  $stderr.puts exit_message if exit_message
  $stdout.reopen(original_stdout) if defined?(original_stdout) and original_stdout
end
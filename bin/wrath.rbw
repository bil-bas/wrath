#!/usr/bin/env ruby

begin
  EXTRACT_PATH = File.dirname(File.dirname(File.expand_path(__FILE__)))

  ROOT_PATH = if ENV['OCRA_EXECUTABLE']
    File.dirname(File.expand_path(ENV['OCRA_EXECUTABLE']))
  else
    EXTRACT_PATH
  end

  APP_NAME = File.basename(__FILE__).chomp(File.extname(__FILE__))
  LOG_FILE = File.join(ROOT_PATH, "#{APP_NAME}_#{Time.now.to_s.gsub(/[^\d]/, "_")}_#{Time.now.usec.to_s.rjust(6, '0')}.log")

  BIN_DIR = File.join(ROOT_PATH, 'bin')
  ENV['PATH'] = "#{BIN_DIR};#{ENV['PATH']}"

  original_stderr = $stderr.dup
  $stderr.reopen LOG_FILE
  $stderr.sync = true

  original_stdout = $stdout.dup
  $stdout.reopen LOG_FILE
  $stdout.sync = true

  require_relative "../lib/wrath"

  exit_message = Wrath::Game.run unless defined? Ocra

rescue => ex
  $stderr.puts "FATAL ERROR - #{ex.class}: #{ex.message}\n#{ex.backtrace.join("\n")}"
  raise ex # Just to make sure that the user sees the error in the CLI/IDE too.
ensure
  $stderr.reopen(original_stderr) if defined? original_stderr
  $stderr.puts exit_message if exit_message
  $stdout.reopen(original_stdout) if defined? original_stdout
end
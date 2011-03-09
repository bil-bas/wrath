#!/usr/bin/env ruby
# encoding: utf-8

begin
  EXTRACT_PATH = File.dirname(File.dirname(File.expand_path(__FILE__)))

  ROOT_PATH = if ENV['OCRA_EXECUTABLE']
    File.dirname(File.expand_path(ENV['OCRA_EXECUTABLE']))
  else
    EXTRACT_PATH
  end

  LOG_FILE = File.join(ROOT_PATH, "#{File.basename($0).chomp(File.extname($0))}.log")

  BIN_DIR = File.join(ROOT_PATH, 'bin')
  ENV['PATH'] = "#{BIN_DIR};#{ENV['PATH']}"

#  original_stderr = $stderr.dup
#  $stderr.reopen LOG_FILE
#  $stderr.sync = true
#
#  original_stdout = $stdout.dup
#  $stdout.reopen LOG_FILE
#  $stdout.sync = true

  $LOAD_PATH.unshift File.expand_path($0).chomp(File.extname($0))
  require 'game'

  exit_message = Game.run unless defined? Ocra

rescue Exception => ex
  $stderr.puts "FATAL ERROR - #{ex.class}: #{ex.message}\n#{ex.backtrace.join("\n")}"
  raise ex # Just to make sure that the user sees the error in the CLI/IDE too.
ensure
  $stderr.puts exit_message if exit_message
  $stderr.reopen(original_stderr) if defined? original_stderr
  $stdout.puts exit_message if exit_message
  $stdout.reopen(original_stdout) if defined? original_stdout
end
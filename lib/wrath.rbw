#!/usr/bin/env ruby
# encoding: utf-8

begin
  EXTRACT_PATH = File.dirname(File.dirname(File.expand_path(__FILE__)))

  ROOT_PATH = if ENV['OCRA_EXECUTABLE']
    File.dirname(File.expand_path(ENV['OCRA_EXECUTABLE']))
  else
    EXTRACT_PATH
  end

  APP_NAME = File.basename($0).chomp(File.extname($0))
  LOG_FILE = File.join(ROOT_PATH, "#{APP_NAME}.log")

  BIN_DIR = File.join(ROOT_PATH, 'bin')
  ENV['PATH'] = "#{BIN_DIR};#{ENV['PATH']}"

  original_stderr = $stderr.dup
  $stderr.reopen LOG_FILE
  $stderr.sync = true

  original_stdout = $stdout.dup
  $stdout.reopen LOG_FILE
  $stdout.sync = true

  $LOAD_PATH.unshift File.expand_path($0).chomp(File.extname($0))
  require 'game'

  exit_message = Wrath::Game.run unless defined? Ocra

rescue => ex
  $stderr.puts "FATAL ERROR - #{ex.class}: #{ex.message}\n#{ex.backtrace.join("\n")}"
  raise ex # Just to make sure that the user sees the error in the CLI/IDE too.
ensure
  $stderr.reopen(original_stderr) if defined? original_stderr
  $stderr.puts exit_message if exit_message
  $stdout.reopen(original_stdout) if defined? original_stdout
end
#!/usr/bin/env ruby
# encoding: utf-8

begin
  ROOT_PATH = if ENV['OCRA_EXECUTABLE']
    File.dirname(File.expand_path(ENV['OCRA_EXECUTABLE']))
  else
    File.dirname(File.dirname(File.expand_path(__FILE__)))
  end

  BIN_DIR = File.join(ROOT_PATH, 'bin')
  ENV['PATH'] = "#{BIN_DIR};#{ENV['PATH']}"

  $LOAD_PATH.unshift File.join($0.chomp(File.extname($0)))

#  original_stderr = $stderr.dup
#  $stderr.reopen File.join(ROOT_PATH, 'game.log')
#  $stderr.sync = true
#
#  original_stdout = $stdout.dup
#  $stdout.reopen File.join(ROOT_PATH, 'game.log')
#  $stdout.sync = true

  require 'game'

  exit_message = Game.run unless defined? Ocra

rescue Exception => ex
  $stderr.puts "FATAL ERROR - #{ex.class}: #{ex.message}\n#{ex.backtrace.join("\n")}"
  raise ex # Just to make sure that the user sees the error in the CLI/IDE too.
ensure
#  $stderr.puts exit_message if exit_message
#  $stderr.reopen(original_stderr) if defined? original_stderr
#  $stdout.puts exit_message if exit_message
#  $stdout.reopen(original_stdout) if defined? original_stdout
end
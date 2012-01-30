Config = RbConfig if defined? RbConfig and not defined? Config # 1.9.3 hack

require 'rake/clean'

APP = "wrath"
APP_READABLE = "Wrath"
require_relative "lib/#{APP}/version"
RELEASE_VERSION = Wrath::VERSION

OSX_GEMS = %w[chingu fidgit clipboard] # Source gems for inclusion in the .app package.

CLEAN.include("*.log")
CLOBBER.include("doc/**/*")

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

require_relative "build/translation"

desc "Translate locale files"
task :translate do
  %w[gui achievements controls].each do |dir|
    lang_dir = File.join(File.dirname(__FILE__), "/config/lang/#{dir}")
    en = File.join(lang_dir, 'en.yml')

    [Pirate, Leet].each do |lang|
      dest = File.join(lang_dir, "en-#{lang::NAME}.yml")
      puts "Created #{dest}"
      lang.translate_yaml_file(en, dest)
    end
  end
end



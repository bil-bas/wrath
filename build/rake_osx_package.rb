# Rake file to make the OS X release
#
# APP, RELEASE_VERSION and RELEASE_FOLDER_BASE must be defined elsewhere.

GAME_URL = "com.github.spooner.#{APP}"
OSX_APP = "#{APP}.app"

RELEASE_FOLDER_OSX = "#{RELEASE_FOLDER_BASE}_OSX_10_6"

OSX_BUILD_DIR =  File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "gosu_wrappers")
BASE_OSX_APP = File.join(OSX_BUILD_DIR, "RubyGosu App.app")
TMP_OSX_PKG_DIR = File.join(OSX_BUILD_DIR, File.basename(RELEASE_FOLDER_OSX))
TMP_OSX_APP = File.join(TMP_OSX_PKG_DIR, OSX_APP)
TMP_OSX_SOURCE_DIR = File.join(TMP_OSX_APP, "Contents", "Resources", APP) # Where I copy my game source.
TMP_OSX_GEM_DIR = File.join(TMP_OSX_APP, "Contents", "Resources", 'lib') # Gem location.
TMP_OSX_INFO_FILE = File.join(TMP_OSX_APP, "Contents", "Info.plist")
TMP_OSX_MAIN_FILE = File.join(TMP_OSX_APP, "Contents", "Resources", "Main.rb")
TMP_OSX_RUBY = File.join(TMP_OSX_APP, "Contents", "MacOS", "RubyGosu App")

desc "Create OS X releases v#{RELEASE_VERSION}"
task release_osx: [:osx_tar_bz2]

# Create folders for release.
file RELEASE_FOLDER_OSX => [OSX_APP, README_HTML] do
  mkdir_p RELEASE_FOLDER_OSX
  cp OSX_APP, RELEASE_FOLDER_OSX
  cp CHANGELOG, RELEASE_FOLDER_OSX
  cp README_HTML, RELEASE_FOLDER_OSX
end

file OSX_APP => :osx_app

desc "Generate #{OSX_APP} (OS X 10.6) v#{RELEASE_VERSION}"
task osx_app: SOURCE_FOLDER_FILES do
  mkdir_p File.dirname(TMP_OSX_APP)

  cp_r BASE_OSX_APP, TMP_OSX_APP

  mkdir_p TMP_OSX_SOURCE_DIR

  # Copy my source files.
  SOURCE_FOLDERS.each {|f| cp_r f, TMP_OSX_SOURCE_DIR }

  # Copy my gems.
  OSX_GEMS.each do |gem|
    gem_path = %x[bundle show #{gem}].chomp
    yardocs = File.join(gem_path, ".yardoc")
    rm_r yardocs if File.exist?(yardocs) # yarddoc is just bloat!
    cp_r gem_path, TMP_OSX_GEM_DIR
  end

  # Something for the .app to run -> just a little redirection file.
  File.open(TMP_OSX_MAIN_FILE, "w") do |file|
    file.puts "require_relative 'wrath/bin/#{APP}.rbw'"
  end

  # Edit the info file to be specific for my game.
  info = File.read(TMP_OSX_INFO_FILE)
  info.sub!('org.libgosu.UntitledGame', GAME_URL)
  info.sub!('RubyGosu App', OSX_APP)
  File.open(TMP_OSX_INFO_FILE, "w") {|f| f.puts info }

  # Ensure execute access to the startup file.
  chmod 0755, TMP_OSX_RUBY
end

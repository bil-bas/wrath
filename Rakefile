require 'rake/clean'
require 'redcloth'
require_relative "lib/wrath/version"

APP = "wrath"
RELEASE_VERSION = Wrath::VERSION

EXECUTABLE = "#{APP}.exe"
SOURCE_FOLDERS = %w[bin config lib media build]
SOURCE_FOLDER_FILES = FileList[SOURCE_FOLDERS.map {|f| "#{f}/**/*"}]
EXTRA_SOURCE_FILES = %w[.gitignore Rakefile README.textile Gemfile Gemfile.lock]

RELEASE_FOLDER = 'pkg'
RELEASE_FOLDER_BASE = File.join(RELEASE_FOLDER, "#{APP}_v#{RELEASE_VERSION.gsub(/\./, '_')}")
RELEASE_FOLDER_WIN32 = "#{RELEASE_FOLDER_BASE}_WIN32"
RELEASE_FOLDER_SOURCE = "#{RELEASE_FOLDER_BASE}_SOURCE"

README_TEXTILE = "README.textile"
README_HTML = "README.html"

CHANGELOG = "CHANGELOG.txt"

CLEAN.include("*.log")
CLOBBER.include("doc/**/*", "wrath.exe", RELEASE_FOLDER, README_HTML)

require_relative 'build/rake_osx_package'
require_relative "build/translation"

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

# Making a release.
file EXECUTABLE => :ocra

desc "Use Ocra to generate #{EXECUTABLE} (Windows only) v#{RELEASE_VERSION}"
task ocra: SOURCE_FOLDER_FILES do
  system "ocra bin/#{APP}.rbw --windows --icon media/icon.ico lib/**/*.yml config/**/*.* media/**/*.* bin/**/*.*"
end

# Making a release.

def compress(package, folder, option = '')
  puts "Compressing #{package}"
  rm package if File.exist? package
  cd 'pkg'
  puts File.basename(package)
  puts %x[7z a #{option} "#{File.basename(package)}" "#{File.basename(folder)}"]
  cd '..'
end

desc "Create release packages v#{RELEASE_VERSION} (Not OSX)"
task release: [:release_source, :release_win32]

desc "Create source releases v#{RELEASE_VERSION}"
task release_source: [:source_zip, :source_7z]

desc "Create win32 releases v#{RELEASE_VERSION}"
task release_win32:  [:win32_zip] # No point making a 7z, since it is same size.

# Create folders for release.
file RELEASE_FOLDER_WIN32 => [EXECUTABLE, README_HTML] do
  mkdir_p RELEASE_FOLDER_WIN32
  cp EXECUTABLE, RELEASE_FOLDER_WIN32
  cp CHANGELOG, RELEASE_FOLDER_WIN32
  cp README_HTML, RELEASE_FOLDER_WIN32
end

file RELEASE_FOLDER_SOURCE => README_HTML do
  mkdir_p RELEASE_FOLDER_SOURCE
  SOURCE_FOLDERS.each {|f| cp_r f, RELEASE_FOLDER_SOURCE }
  cp EXTRA_SOURCE_FILES, RELEASE_FOLDER_SOURCE
  cp CHANGELOG, RELEASE_FOLDER_SOURCE
  cp README_HTML, RELEASE_FOLDER_SOURCE
end

{ "7z" => '', :zip => '-tzip' }.each_pair do |compression, option|
  { source: RELEASE_FOLDER_SOURCE, win32: RELEASE_FOLDER_WIN32}.each_pair do |name, folder|
    package = "#{folder}.#{compression}"
    desc "Create #{package}"
    task :"#{name}_#{compression}" => package
    file package => folder do
      compress(package, folder, option)
    end
  end
end

# Generate a friendly readme
file README_HTML => :readme
desc "Convert readme to HTML"
task :readme => README_TEXTILE do
  puts "Converting readme to HTML"
  File.open(README_HTML, "w") do |file|
    file.write RedCloth.new(File.read(README_TEXTILE)).to_html
  end
end

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



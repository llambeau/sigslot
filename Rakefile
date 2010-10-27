require 'rubygems'
require "rake/testtask"
require "rake/gempackagetask"
require "rake/rdoctask"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "sigslot.rb")
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d)\1/, 2]

task :default => [:all]

task :all => [:test]

task :test => [:unit]

desc "Lauches all unit tests"
Rake::TestTask.new(:unit) do |test|
  test.libs       = [ "lib" ]
  test.test_files = ['test/test_unit.rb']
  test.verbose    =  true
end

desc "Generates rdoc documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README.textile", "LICENCE.textile", "CHANGELOG.textile", "TODO.textile", "lib/" )
  rdoc.main     = "README.textile"
  rdoc.rdoc_dir = "doc/api"
  rdoc.title    = "SigSlot Documentation"
end

desc "Generates gem package"
gemspec = Gem::Specification.new do |s|
  s.name = 'sigslot'
  s.version = version
  s.summary = "Signal And Slots for ruby"
  s.description = %{An attempt to provide signals and slots in ruby (as Qt's concept)}
  s.files = Dir['lib/**/*'] + Dir['test/**/*']
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.textile", "LICENCE.textile"]
  s.rdoc_options << '--title' << 'SigSlot - Signals and Slots for ruby' <<
                    '--main' << 'README.textile' <<
                    '--line-numbers'  
  s.author = "Louis Lambeau"
  s.email = "louislambeau@gmail.com"
  s.homepage = "http://github.com/llambeau/sigslot"
end
Rake::GemPackageTask.new(gemspec) do |pkg|
	pkg.need_tar = true
end


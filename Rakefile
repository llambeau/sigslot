require 'rubygems'
require "rake/testtask"

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
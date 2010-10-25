$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'test/unit'
test_files = Dir[File.join(File.dirname(__FILE__), 'unit/test*.rb')]
test_files.each { |file|
  require(file) 
}
require "micro_test"
require "micro_mock"

Dir[File.join(File.dirname(__FILE__), "..", "lib", "*.rb")].each do |file|
  require file
end

require "pry-test"
require "spoof"
require "coveralls"

Coveralls.wear!
SimpleCov.command_name "pry-test"

Dir[File.expand_path("../../lib/*.rb", __FILE__)].each do |file|
  require file
end

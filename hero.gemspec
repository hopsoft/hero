# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), "lib", "hero", "version")

Gem::Specification.new do |gem|
  gem.name        = "hero"
  gem.license     = "MIT"
  gem.version     = Hero::VERSION
  gem.authors     = ["Nathan Hopkins"]
  gem.email       = ["natehop@gmail.com"]
  gem.homepage    = "https://github.com/hopsoft/hero"
  gem.summary     = "A simplified state machine."
  gem.description = "A simplified state machine."

  gem.files       = Dir["lib/**/*.rb", "bin/*", "[A-Z]*"]
  gem.test_files  = Dir["test/**/*.rb"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-stack_explorer"
  gem.add_development_dependency "pry-rescue"
  gem.add_development_dependency "pry-test"
  gem.add_development_dependency "spoof"
end


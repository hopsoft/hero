require "rake"
require File.join(File.dirname(__FILE__), "lib", "hero", "version")

Gem::Specification.new do |spec|
  spec.name = "hero"
  spec.version = Hero::VERSION
  spec.license = "MIT"
  spec.homepage = "http://hopsoft.github.com/hero/"
  spec.summary = "You can think of Hero as a simplified state machine."
  spec.description = <<-DESC
    Simplify your app by effectively modeling business processes within it.
  DESC

  spec.authors = ["Nathan Hopkins"]
  spec.email = ["natehop@gmail.com"]

  spec.files = FileList[
    "lib/**/*.rb",
    "bin/*",
    "[A-Z]*",
    "spec/**/*.rb"
  ]
end


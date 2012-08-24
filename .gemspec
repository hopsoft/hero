require 'rake'

Gem::Specification.new do |spec|
  spec.name = 'hero'
  spec.version = '0.0.4'
  spec.license = 'MIT'
  spec.homepage = 'http://hopsoft.github.com/hero/'
  spec.summary = 'Business process modeling for the Rubyist'
  spec.description = <<-DESC
    Simplify your apps with Hero.
  DESC

  spec.authors = ['Nathan Hopkins']
  spec.email = ['natehop@gmail.com']

  spec.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'spec/**/*.rb'].to_a
end


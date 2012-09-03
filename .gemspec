require 'rake'

Gem::Specification.new do |spec|
  spec.name = 'hero'
  spec.version = '0.1.1'
  spec.license = 'MIT'
  spec.homepage = 'http://hopsoft.github.com/hero/'
  spec.summary = 'Hero saves the day by aligning your implementation to business processes.'
  spec.description = <<-DESC
    Simplify your app by effectively modeling business processes within it.
  DESC

  spec.authors = ['Nathan Hopkins']
  spec.email = ['natehop@gmail.com']

  spec.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'spec/**/*.rb'].to_a
end


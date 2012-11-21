require "bundler"
Bundler.require :default, :development

Dir[File.join(File.dirname(__FILE__), "..", "lib", "*.rb")].each do |file|
  require file
end

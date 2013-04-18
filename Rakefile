require "bundler/gem_tasks"

task :default => [:test]

desc "Runs the test suite."
task :test do
  ENV["TEST"] = "1"
  output = `bundle exec mt`
  puts output
  exit output.index(/tests\sfinished.*failed/).nil?
end

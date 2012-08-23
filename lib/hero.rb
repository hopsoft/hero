Dir[File.join(File.dirname(__FILE__), "hero", "*rb")].each do |file|
  require file
end

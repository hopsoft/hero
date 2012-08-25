Dir[File.join(File.dirname(__FILE__), "hero", "*rb")].each do |file|
  require file
end

module Hero
  class << self

    # You can optionally register a Logger with Hero.
    # If set, a logger.info message will be written for each step called when running Hero::Formulas.
    #
    # @example
    #   Hero.logger = Logger.new(STDOUT)
    attr_accessor :logger

  end
end

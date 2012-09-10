module Hero

  # Hero::Observer is designed to observe Hero::Formulas.
  # It executes all registered steps whenever Hero::Formula#run is invoked.
  # A Hero::Formula should only have 1 Hero::Observer attached.
  class Observer

    # The name of the Hero::Formula being observed.
    attr_reader :formula_name

    # @param [Symbol, String] formula_name The name of the Hero::Formula being observed.
    def initialize(formula_name)
      @formula_name = formula_name
    end

    # @return [Array] All registered steps.
    def steps
      @steps ||= []
    end

    # Adds a step to be executed when the Hero::Formula is run.
    # @note Steps are called in the order they are added. 1st in 1st invoked.
    #
    # @example A step must implement the interface.
    #   def call(*args)
    #
    #   # or more specifically
    #   def call(context, options={})
    #
    # @example Add a step using a block.
    #   add_step(:my_step) do |context, options|
    #     # logic here...
    #   end
    #
    # @example Add a step using an Object.
    #   class MyStep
    #     def self.call(context, options={})
    #       # logic here...
    #     end
    #   end
    #
    #   add_step(MyStep)
    #
    # @param optional [Symbol, String] name The name of the step.
    # @param optional [Object] step The step to be executed.
    # @block optional [Object] A block to use as the step to be executed.
    def add_step(*args, &block)
      if block_given?
        raise ArgumentError unless args.length == 1
        name = args.first
        step = block
      else
        raise ArgumentError if args.length > 2
        if args.length == 1
          step = args.first
        elsif args.length == 2
          name = args.first
          step = args.last
        end
      end

      name ||= step.name if step.is_a? Class
      name ||= step.class.name

      steps.delete_if { |s| s.first == name }
      step ||= block if block_given?
      steps << [name, step]
    end

    # The callback triggered when Hero::Formula#run is invoked.
    # This method runs all registered steps in order.
    #
    # @note A log message will be written to Hero.logger for each step that is called if Hero.logger has been set.
    #
    # @param optional [Object] context The context to be passed to each step.
    # @param optional [Hash] options An option Hash to be passed to each step.
    def update(context=nil, options={})
      steps.each do |step|
        log_step(:before, step, context, options)
        begin
          step.last.call(context, options)
        rescue Exception => ex
          log_step(:error, step, context, options, ex)
          raise ex
        end
        log_step(:after, step, context, options)
      end
    end

    private


    # Logs a step to the registered Hero.logger.
    # @note Users info for the log level.
    # @param [Symbol, String] id The identifier for the step. [:before, :after]
    # @param [Object] step
    # @param [Object] context
    # @param [Object] options
    def log_step(id, step, context, options, error=nil)
      return unless Hero.logger
      if error
        Hero.logger.error "HERO #{id.to_s.ljust(6)} #{formula_name} -> #{step.first} Context: #{context.inspect} Options: #{options.inspect} Error: #{error.message}"
      else
        Hero.logger.info "HERO #{id.to_s.ljust(6)} #{formula_name} -> #{step.first} Context: #{context.inspect} Options: #{options.inspect}"
      end
    end

  end
end


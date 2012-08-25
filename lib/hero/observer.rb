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
    #
    # @example A step must implement the interface
    #   def call(*args)
    #
    # @example More specifically
    #   def call(context, options={})
    #
    # The simplest example being a Proc.
    #
    # @note Steps are called in the order they are added. 1st in 1st called
    #
    # @example
    #   add_step(:my_step) do |context, options|
    #     # logic here...
    #   end
    #
    # @example
    #   class MyStep
    #     def self.call(context, options={})
    #       # logic here...
    #     end
    #   end
    #
    #   add_step(:my_step, MyStep)
    #
    # @param [Symbol, String] name The name of the step.
    # @param optional [Object] step The step to be executed.
    # @yield optional [Object, Hash] Uses a passed block as the step to be executed.
    def add_step(name, step=nil, &block)
      steps.delete_if { |s| s.first == name }
      step ||= block if block_given?
      steps << [name, step]
    end

    # The callback triggered when Hero::Formula#run is invoked.
    # This method runs all registered steps in order.
    #
    # @note A log message will be written to Hero.logger for each step that is called if Hero.logger has been set.
    #
    # @param [Object] context The context to be passed to each step.
    # @param [Hash] options An option Hash to be passed to each step.
    def update(context, options={})
      steps.each do |step|
        if Hero.logger
          Hero.logger.info "HERO Formula: #{formula_name}, Step: #{step.first}, Context: #{context.inspect}, Options: #{options.inspect}"
        end
        step.last.call(context, options)
      end
    end

  end
end


module Hero
  class Observer
    attr_reader :formula_name

    def initialize(formula_name)
      @formula_name = formula_name
    end

    def steps
      @steps ||= []
    end

    def add_step(name, step=nil, &block)
      steps.delete_if { |s| s.first == name }
      step ||= block if block_given?
      steps << [name, step]
    end

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


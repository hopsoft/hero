module Hero
  class Observer
    attr_reader :formula_name

    def initialize(formula_name)
      @formula_name = formula_name
    end

    def steps
      @steps ||= {}
      @steps.sort{ |a, b| a.last[:index] <=> b.last[:index] }.map{ |k, v| { k => v[:step] } }
    end

    def add_step(name, step=nil, &block)
      @steps ||= {}
      step ||= block if block_given?
      @steps[name] = { :step => step, :index => @steps.length }
    end

    def update(context, options={})
      steps.each do |step|
        if Hero.logger
          Hero.logger.info "HERO Formula: #{formula_name}, Step: #{step.keys.first}, Context: #{context.inspect}, Options: #{options.inspect}"
        end
        step.values.first.call(context, options)
      end
    end

  end
end


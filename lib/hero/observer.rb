module Hero
  class Observer

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
      steps.each { |step| step.values.first.call(context, options) }
    end

  end
end


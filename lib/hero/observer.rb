module Hero
  class Observer

    def steps
      @steps ||= []
    end

    def update(context, options={})
      steps.each { |step| step.call(context, options) }
    end

  end
end

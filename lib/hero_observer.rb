module Hero
  class Observer

    def steps
      @steps ||= []
    end

    def update(target, options={})
      steps.each { |step| step.call(target, options) }
    end

  end
end

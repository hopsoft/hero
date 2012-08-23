require 'observer'
require 'singleton'
require 'forwardable'

module Hero
  class Formula
    include Observable
    include Singleton

    class << self
      extend Forwardable
      def_delegator :formulas, :each, :each
      def_delegator :formulas, :length, :count

      def reset
        @formulas = {}
      end

      def [](name)
        formulas[name] ||= register(name)
      end

      def register(name)
        observer = Hero::Observer.new
        formula = Class.new(Hero::Formula).instance
        formula.add_observer(observer)
        formula.instance_eval { @observer = observer }
        formulas[name] = formula
      end

      private

      def formulas
        @formulas ||= {}
      end
    end

    def add_step(step=nil, &block)
      step ||= block if block_given?
      @observer.steps << step
    end

    def notify(context=nil, options={})
      changed
      notify_observers(context, options)
    end

    alias :run :notify

  end
end


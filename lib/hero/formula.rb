require 'observer'
require 'singleton'
require 'forwardable'

module Hero
  class Formula

    # Class attributes & methods ==============================================
    class << self
      extend Forwardable
      def_delegator :formulas, :each, :each
      def_delegator :formulas, :length, :count

      def reset
        formulas.values.each { |f| f.delete_observers }
        @formulas = {}
      end

      def [](name)
        formulas[name] ||= register(name)
      end

      def register(name)
        observer = Hero::Observer.new
        formula = Class.new(Hero::Formula).instance
        formula.add_observer(observer)
        formula.instance_eval do
          @name = name
          @observer = observer
        end
        formulas[name] = formula
      end

      private

      def formulas
        @formulas ||= {}
      end
    end

    # Instance attributes & methods ===========================================
    extend Forwardable
    include Observable
    include Singleton

    attr_reader :name, :observer
    def_delegator :observer, :steps, :steps
    def_delegator :observer, :add_step, :add_step

    def inspect
      value = [name]
      steps.each_with_index do |step, index|
        value << "#{(index + 1).to_s.rjust(3)}. #{step.keys.first}"
      end
      value.join("\n")
    end

    def notify(context=nil, options={})
      changed
      notify_observers(context, options)
    end

    alias :run :notify

  end
end


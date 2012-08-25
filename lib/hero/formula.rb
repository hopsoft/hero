require 'observer'
require 'singleton'
require 'forwardable'
require File.join(File.dirname(__FILE__), "observer")

module Hero

  class Formula

    # Class attributes & methods ==============================================
    class << self
      extend Forwardable
      def_delegator :formulas, :each, :each
      def_delegator :formulas, :length, :count

      def publish
        value = []
        each do |name, formula|
          value << formula.publish
        end
        value.join("\n\n")
      end

      def reset
        formulas.values.each { |f| f.delete_observers }
        @formulas = {}
      end

      def [](name)
        formulas[name] ||= register(name)
      end

      def register(name)
        observer = Hero::Observer.new(name)
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

    def publish
      value = [name]
      steps.each_with_index do |step, index|
        value << "#{(index + 1).to_s.rjust(3)}. #{step.first}"
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


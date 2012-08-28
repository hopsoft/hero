require 'observer'
require 'singleton'
require 'forwardable'
require File.join(File.dirname(__FILE__), "observer")

module Hero

  # Represents a business process that can be easily modeled and implemented.
  #
  # The idea is to encourage implementations that more closely resemble
  # business requirements in order to reduce the dissonance
  # that is typical between business nomenclature and actual implementation.
  #
  # Additional benefits include:
  # * Composable units of code which support changing requirements
  # * Testable components
  # * Simplified implementation
  #
  # @example A basic example.
  #   Hero::Formula[:checkout].add_step(:total) do |context, options|
  #     # total order (apply discounts etc...)
  #   end
  #
  #   Hero::Formula[:checkout].add_step(:charge) do |context, options|
  #     # charge for order (handle failure and timeouts gracefully etc...)
  #   end
  #
  #   Hero::Formula[:checkout].add_step(:complete) do |context, options|
  #     # handle shipping arrangements and follow up email etc...
  #   end
  class Formula

    # Class attributes & methods ==============================================
    class << self
      extend Forwardable

      # Iterates over all registered formulas.
      def_delegator :formulas, :each, :each

      # Indicates the total number of registered formulas.
      def_delegator :formulas, :length, :count

      # Prints/puts a string representation of all registered formulas.
      def print
        formulas.values.each(&:print)
      end

      # Removes all registered formulas.
      def reset
        formulas.values.each { |f| f.delete_observers }
        @formulas = {}
      end

      # Returns the named formula.
      # @note Implicitly registers the formula if it has not already been registered.
      # @param [Symbol, String] name The name of the formula.
      # @return Hero::Formula
      def [](name)
        formulas[name] ||= register(name)
      end

      # Registers a formula an prepares it to receive steps.
      # @param [Symbol, String] name The name of the formula.
      # @return Hero::Formula
      def register(name)
        observer = Hero::Observer.new(name)
        formula_class_name = name.to_s.strip.gsub(/\s/, "_").gsub(/[^a-z_]/i, "").split(/_/).map(&:capitalize).join
        formula_class = Class.new(Hero::Formula)
        if Hero::Formula.const_defined?(formula_class_name)
          Hero::Formula.send(:remove_const, formula_class_name)
        end
        Hero::Formula.const_set(formula_class_name, formula_class)
        formula = formula_class.instance
        formula.add_observer(observer)
        formula.instance_eval do
          @name = name
          @observer = observer
        end
        formulas[name] = formula
      end

      private

      # Returns a Hash of all registered formulas.
      def formulas
        @formulas ||= {}
      end
    end

    # Instance attributes & methods ===========================================
    extend Forwardable
    include Observable
    include Singleton

    # The name of this formula.
    attr_reader :name

    # The observer attached to this formula.
    attr_reader :observer

    # All registered steps.
    def_delegator :observer, :steps, :steps

    # Adds a step to be executed when this formula is run.
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
    #   add_step(:my_step, MyStep)
    #
    # @param [Symbol, String] name The name of the step.
    # @param optional [Object] step The step to be executed.
    # @block optional [Object] A block to use as the step to be executed.
    def_delegator :observer, :add_step, :add_step

    # Observable notify implementation.
    # Invokes #update on all observers.
    # @param optional [Object] context The context to be passed to each step.
    # @param optional [Hash] options An option Hash to be passed to each step.
    def notify(context=nil, options={})
      changed
      notify_observers(context, options)
    end

    alias :run :notify

    # Prints/puts a String representation of the formula.
    # @example
    #   Hero::Formula[:example].add_step(:one) {}
    #   Hero::Formula[:example].add_step(:two) {}
    #   Hero::Formula[:example].add_step(:three) {}
    #   Hero::Formula[:example].to_s # => "example\n  1. one\n  2. two\n  3. three"
    def print
      value = [name]
      steps.each_with_index do |step, index|
        value << "#{(index + 1).to_s.rjust(3)}. #{step.first}"
      end
      puts value.join("\n")
    end

  end
end


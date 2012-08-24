require "spec_helper"

describe Hero::Formula do
  include GrumpyOldMan

  before :each do
    Hero.logger = nil
    Hero::Formula.reset
  end

  it "should support reset" do
    Hero::Formula.register(:test_formula)
    assert_equal Hero::Formula.count, 1
    Hero::Formula.reset
    assert_equal Hero::Formula.count, 0
  end

  it "should support registering a formula" do
    Hero::Formula.register(:test_formula)
    assert_equal Hero::Formula.count, 1
    assert Hero::Formula[:test_formula].is_a? Hero::Formula
  end

  it "should auto register formulas" do
    Hero::Formula[:test_formula]
    assert_equal Hero::Formula.count, 1
    assert Hero::Formula[:test_formula].is_a? Hero::Formula
  end

  it "should support registering N number of formulas" do
    10.times { |i| Hero::Formula.register("example_#{i}") }
    assert_equal Hero::Formula.count, 10
  end

  it "should unregister formula observers on reset" do
    formula = Hero::Formula[:test_formula]
    assert_equal Hero::Formula.count, 1
    formula.add_step(:one) {}
    assert_equal formula.count_observers, 1
    Hero::Formula.reset
    assert_equal Hero::Formula.count, 0
    assert_equal formula.count_observers, 0
  end

  it "should publish all formulas" do
    Hero::Formula[:first].add_step(:one) {}
    Hero::Formula[:first].add_step(:two) {}
    Hero::Formula[:first].add_step(:three) {}
    Hero::Formula[:first].add_step(:four) {}

    Hero::Formula[:second].add_step(:one) {}
    Hero::Formula[:second].add_step(:two) {}
    Hero::Formula[:second].add_step(:three) {}
    Hero::Formula[:second].add_step(:four) {}

    expected = "first  1. one  2. two  3. three  4. foursecond  1. one  2. two  3. three  4. four"
    assert_equal Hero::Formula.publish.gsub(/\n/, ""), expected
  end

  describe "a registered formula" do
    it "should support adding steps" do
      Hero::Formula[:test_formula].add_step(:one) { }
      assert_equal Hero::Formula.count, 1
      assert_equal Hero::Formula[:test_formula].steps.length, 1
    end

    def invoke_notify_method(name)
      step_ran = false
      target = Object.new
      Hero::Formula[:test_formula].add_step(:one) do |t, opts|
        assert_equal t, target
        assert_equal opts[:foo], :bar
        step_ran = true
      end
      Hero::Formula[:test_formula].notify(target, :foo => :bar)
      assert step_ran
    end

    it "should support notify" do
      invoke_notify_method(:notify)
    end

    it "should support run" do
      invoke_notify_method(:run)
    end

    it "should support running multiple tests" do
      log = {}
      Hero::Formula[:test_formula].add_step(:one) { |o, l| l[:one] = true }
      Hero::Formula[:test_formula].add_step(:two) { |o, l| l[:two] = true }
      Hero::Formula[:test_formula].run(self, log)
      assert log[:one]
      assert log[:two]
    end

    it "should publish all steps in the formula" do
      Hero::Formula[:test_formula].add_step(:one) {}
      Hero::Formula[:test_formula].add_step(:two) {}
      Hero::Formula[:test_formula].add_step(:three) {}
      Hero::Formula[:test_formula].add_step(:four) {}
      expected = "test_formula  1. one  2. two  3. three  4. four"
      assert_equal Hero::Formula[:test_formula].publish.gsub(/\n/, ""), expected
    end

    it "should support logging" do
      class TestLogger
        attr_reader :buffer
        def info(value)
          @buffer ||= []
          @buffer << value
        end
      end
      Hero.logger = TestLogger.new
      Hero::Formula[:test_formula].add_step(:one) {}
      Hero::Formula[:test_formula].add_step(:two) {}
      Hero::Formula[:test_formula].run(:example, :logging => true)
      assert_equal Hero.logger.buffer.length, 2
      assert_equal "HERO Formula: test_formula, Step: one, Context: :example, Options: {:logging=>true}", Hero.logger.buffer.first
      assert_equal "HERO Formula: test_formula, Step: two, Context: :example, Options: {:logging=>true}", Hero.logger.buffer.last
    end

  end

end


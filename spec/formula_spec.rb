require "spec_helper"

describe Hero::Formula do
  include GrumpyOldMan

  before :each do
    Hero.logger = nil
    Hero::Formula.reset
  end

  it "should not allow anonymous steps" do
    assert_raise ArgumentError do
      Hero::Formula[:test_formula].add_step() {}
    end
  end

  it "should allow unnamed Class steps" do
    class MyStep
      def self.call(*args); end
    end
    Hero::Formula[:test_formula].add_step MyStep
    assert Hero::Formula[:test_formula].steps.map{|s| s.first}.include?("MyStep")
    assert Hero::Formula[:test_formula].steps.map{|s| s.last}.include?(MyStep)
  end

  it "should allow named Class steps" do
    class MyStep
      def self.call(*args); end
    end
    Hero::Formula[:test_formula].add_step :foo, MyStep
    assert Hero::Formula[:test_formula].steps.map{|s| s.first}.include?(:foo)
    assert Hero::Formula[:test_formula].steps.map{|s| s.last}.include?(MyStep)
  end

  it "should allow unnamed instance steps" do
    class MyStep
      def call(*args); end
    end
    step = MyStep.new
    Hero::Formula[:test_formula].add_step step
    names = Hero::Formula[:test_formula].steps.map{|s| s.first}
    steps = Hero::Formula[:test_formula].steps.map{|s| s.last}
    steps.each { |s| assert s.is_a? MyStep }
    assert names.include?("MyStep")
    assert steps.include?(step)
  end

  it "should allow named instance steps" do
    class MyStep
      def call(*args); end
    end
    step = MyStep.new
    Hero::Formula[:test_formula].add_step :foo, step
    names = Hero::Formula[:test_formula].steps.map{|s| s.first}
    steps = Hero::Formula[:test_formula].steps.map{|s| s.last}
    steps.each { |s| assert s.is_a? MyStep }
    assert names.include?(:foo)
    assert steps.include?(step)
  end

  it "should create a named class" do
    Hero::Formula[:my_formula]
    assert Object.const_defined?("HeroFormulaMyFormula")
    assert_equal Hero::Formula[:my_formula].class.name, "HeroFormulaMyFormula"
    assert Hero::Formula[:my_formula].is_a? HeroFormulaMyFormula
  end

  it "should safely create a named class" do
    Hero::Formula["A long and cr@zy f0rmul@ name ~12$%"]
    assert Hero::Formula.const_defined?("HeroFormulaALongAndCrzyFrmulName")
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

    begin
      out = StringIO.new
      $stdout = out
      Hero::Formula.print
      expected = "first\n  1. one\n  2. two\n  3. three\n  4. four\nsecond\n  1. one\n  2. two\n  3. three\n  4. four\n"
      out.rewind
      assert_equal out.readlines.join, expected
    ensure
      $stdout = STDOUT
    end
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

    it "should support running step defined in a class" do
      class Step
        def call(context, options)
          options[:context] = context
        end
      end

      opts = {}
      Hero::Formula[:test_formula].add_step(:one, Step.new)
      Hero::Formula[:test_formula].run(:foo, opts)
      assert_equal opts[:context], :foo
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
      begin
        out = StringIO.new
        $stdout = out
        Hero::Formula[:test_formula].print
        expected = "test_formula\n  1. one\n  2. two\n  3. three\n  4. four\n"
        out.rewind
        assert_equal out.readlines.join, expected
      ensure
        $stdout = STDOUT
      end
    end

    it "should support logging" do
      class TestLogger
        attr_reader :buffer
        def initialize; @buffer = []; end
        def info(value); @buffer << value; end
        alias :error :info
      end
      Hero.logger = TestLogger.new

      Hero::Formula[:test_formula].add_step(:one) { |list, opts| list << 1; opts[:step] = 1 }
      Hero::Formula[:test_formula].add_step(:two) { |list, opts| list << 2; opts[:step] = 2 }
      list = []
      Hero::Formula[:test_formula].run(list, {})
      assert_equal Hero.logger.buffer.length, 4
      assert_equal "HERO before test_formula -> one Context: [] Options: {}", Hero.logger.buffer[0]
      assert_equal "HERO after  test_formula -> one Context: [1] Options: {:step=>1}", Hero.logger.buffer[1]
      assert_equal "HERO before test_formula -> two Context: [1] Options: {:step=>1}", Hero.logger.buffer[2]
      assert_equal "HERO after  test_formula -> two Context: [1, 2] Options: {:step=>2}", Hero.logger.buffer[3]
    end

    it "should support logging errors" do
      class TestLogger
        attr_reader :info_count, :error_count, :buffer
        def initialize; @info_count = 0; @error_count = 0; @buffer = []; end
        def info(value); @info_count += 1; @buffer << value; end
        def error(value); @error_count += 1; @buffer << value; end
      end
      Hero.logger = TestLogger.new
      Hero::Formula[:test_formula].add_step(:one) { |list, opts| raise Exception.new("fubar") }
      assert_raise(Exception) { Hero::Formula[:test_formula].run }
      assert_equal Hero.logger.buffer.length, 2
      assert_equal Hero.logger.info_count, 1
      assert_equal Hero.logger.error_count, 1
    end

  end

end


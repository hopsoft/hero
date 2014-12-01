require "thread"
require File.expand_path("../test_helper", __FILE__)

class FormulaTest < PryTest::Test
  class << self
    attr_accessor :formula_count
    def mutex
      @mutex = Mutex.new
    end
  end

  module Helper
    def invoke_notify_method(name)
      step_ran = false
      target = Object.new
      Hero::Formula[@formula_name].add_step(:one) do |t, opts|
        assert t == target
        assert opts[:foo] == :bar
        step_ran = true
      end
      Hero::Formula[@formula_name].notify(target, :foo => :bar)
      assert step_ran
    end
  end

  before do
    self.class.send :include, Helper

    FormulaTest.mutex.synchronize do
      FormulaTest.formula_count ||= 0
      @formula_name = "test_formula_#{FormulaTest.formula_count += 1}"
    end
  end

  test "should not allow anonymous steps" do
    err = nil
    begin
      Hero::Formula[@formula_name].add_step() {}
    rescue ArgumentError
      err = $!
    end
    assert err.is_a?(ArgumentError)
  end

  test "should allow unnamed Class steps" do
    step = Spoof.make
    step.method(:call) {}
    Hero::Formula[@formula_name].add_step step
    assert Hero::Formula[@formula_name].steps.map{|s| s.first}.first =~ /Spoof/
    assert Hero::Formula[@formula_name].steps.map{|s| s.last}.include?(step)
  end

  test "should allow named Class steps" do
    step = Spoof.make
    step.method(:call) {}
    Hero::Formula[@formula_name].add_step :foo, step
    assert Hero::Formula[@formula_name].steps.map{|s| s.first}.include?(:foo)
    assert Hero::Formula[@formula_name].steps.map{|s| s.last}.include?(step)
  end

  test "should allow unnamed instance steps" do
    step = Spoof.make.new
    step.method(:call) {}
    Hero::Formula[@formula_name].add_step step
    names = Hero::Formula[@formula_name].steps.map{|s| s.first}
    steps = Hero::Formula[@formula_name].steps.map{|s| s.last}
    steps.each { |s| assert s.is_a? Spoof }
    assert names.first =~ /Spoof/i
    assert steps.include?(step)
  end

  test "should allow named instance steps" do
    step = Spoof.make.new
    step.method(:call) {}
    Hero::Formula[@formula_name].add_step :foo, step
    names = Hero::Formula[@formula_name].steps.map{|s| s.first}
    steps = Hero::Formula[@formula_name].steps.map{|s| s.last}
    steps.each { |s| assert s.is_a? Spoof }
    assert names.include?(:foo)
    assert steps.include?(step)
  end

  test "should create a named class" do
    Hero::Formula[:my_formula]
    assert Object.const_defined?("HeroFormulaMyFormula")
    assert Hero::Formula[:my_formula].class.name == "HeroFormulaMyFormula"
    assert Hero::Formula[:my_formula].is_a? HeroFormulaMyFormula
  end

  test "should safely create a named class" do
    Hero::Formula["A long and cr@zy f0rmul@ name ~12$%"]
    assert Hero::Formula.const_defined?("HeroFormulaALongAndCrzyFrmulName")
  end

  # test "should support reset" do
  #   Hero::Formula.register(@formula_name)
  #   assert Hero::Formula.count >= 1
  #   Hero::Formula.reset
  #   assert Hero::Formula.count == 0
  # end

  test "should support registering a formula" do
    Hero::Formula.register(@formula_name)
    assert Hero::Formula.count >= 1
    assert Hero::Formula[@formula_name].is_a? Hero::Formula
  end

  test "should auto register formulas" do
    Hero::Formula[@formula_name]
    assert Hero::Formula.count >= 1
    assert Hero::Formula[@formula_name].is_a? Hero::Formula
  end

  test "should support registering N number of formulas" do
    10.times { |i| Hero::Formula.register("example_#{i}") }
    assert Hero::Formula.count >= 10
  end

  # test "should unregister formula observers on reset" do
  #   formula = Hero::Formula[@formula_name]
  #   assert Hero::Formula.count == 1
  #   formula.add_step(:one) {}
  #   assert formula.count_observers == 1
  #   Hero::Formula.reset
  #   assert Hero::Formula.count == 0
  #   assert formula.count_observers == 0
  # end

  test "should publish all formulas" do
    Hero::Formula.reset
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
      expected = /first\n  1\. one\n  2\. two\n  3\. three\n  4\. four\nsecond\n  1\. one\n  2\. two\n  3\. three\n  4\. four\n/
      out.rewind
      assert out.readlines.join =~ expected
    ensure
      $stdout = STDOUT
    end
  end

  # describe "a registered formula" do
  test "should support adding steps" do
    Hero::Formula[@formula_name].add_step(:one) { }
    assert Hero::Formula.count >= 1
    assert Hero::Formula[@formula_name].steps.length == 1
  end

  test "should support notify" do
    invoke_notify_method(:notify)
  end

  test "should support run" do
    invoke_notify_method(:run)
  end

  test "should support running step defined in a class" do
    step = Spoof.make.new
    step.method(:call) do |context, options|
      options[:context] = context
    end

    opts = {}
    Hero::Formula[@formula_name].add_step(:one, step)
    Hero::Formula[@formula_name].run(:foo, opts)
    assert opts[:context] == :foo
  end

  test "should support running multiple tests" do
    log = {}
    Hero::Formula[@formula_name].add_step(:one) { |o, l| l[:one] = true }
    Hero::Formula[@formula_name].add_step(:two) { |o, l| l[:two] = true }
    Hero::Formula[@formula_name].run(self, log)
    assert log[:one]
    assert log[:two]
  end

  test "should publish all steps in the formula" do
    Hero::Formula[@formula_name].add_step(:one) {}
    Hero::Formula[@formula_name].add_step(:two) {}
    Hero::Formula[@formula_name].add_step(:three) {}
    Hero::Formula[@formula_name].add_step(:four) {}
    expected = "test_formula  1. one  2. two  3. three  4. four"
    begin
      out = StringIO.new
      $stdout = out
      Hero::Formula[@formula_name].print
      expected = "#{@formula_name}\n  1. one\n  2. two\n  3. three\n  4. four\n"
      out.rewind
      assert out.readlines.join.include?(expected)
    ensure
      $stdout = STDOUT
    end
  end

  test "should support logging" do
    FormulaTest.mutex.synchronize do
      logger = Spoof.make.new
      logger.attr :buffer
      logger.buffer = []
      logger.method(:info) { |value| buffer << value }
      logger.method(:error) { |value| buffer << value }
      Hero.logger = logger

      Hero::Formula[@formula_name].add_step(:one) { |list, opts| list << 1; opts[:step] = 1 }
      Hero::Formula[@formula_name].add_step(:two) { |list, opts| list << 2; opts[:step] = 2 }
      list = []
      Hero::Formula[@formula_name].run(list, {})
      assert Hero.logger.buffer.length == 4
      assert Hero.logger.buffer[0] =~ /HERO before test_formula_[0-9]+ -> one Context: \[\] Options: \{\}/
      assert Hero.logger.buffer[1] =~ /HERO after  test_formula_[0-9]+ -> one Context: \[1\] Options: \{:step=>1\}/
      assert Hero.logger.buffer[2] =~ /HERO before test_formula_[0-9]+ -> two Context: \[1\] Options: \{:step=>1\}/
      assert Hero.logger.buffer[3] =~ /HERO after  test_formula_[0-9]+ -> two Context: \[1, 2\] Options: \{:step=>2\}/
    end
  end

  # test "should support logging errors" do
  #   FormulaTest.mutex.synchronize do
  #     logger = Spoof.make.new
  #     logger.attr :buffer
  #     logger.attr(:info_count)
  #     logger.attr(:error_count)
  #     logger.method(:info) { |value| buffer << value; self.info_count += 1 }
  #     logger.method(:error) { |value| buffer << value; self.error_count += 1 }
  #     logger.buffer = []
  #     logger.info_count = 0
  #     logger.error_count = 0
  #     Hero.logger = logger
  #     Hero::Formula[@formula_name].add_step(:one) { |list, opts| raise Exception.new("fubar") }
  #     err = nil
  #     begin
  #       Hero::Formula[@formula_name].run
  #     rescue Exception
  #       err = $!
  #     end
  #     assert err.is_a?(Exception)
  #     assert Hero.logger.buffer.length == 2
  #     assert Hero.logger.info_count == 1
  #     assert Hero.logger.error_count == 1
  #   end
  # end

end

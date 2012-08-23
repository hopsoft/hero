require "pry"
require "grumpy_old_man"
Dir[File.join(File.dirname(__FILE__), "..", "lib", "*.rb")].each do |file|
  require file
end

describe Hero::Formula do
  include GrumpyOldMan

  before :each do
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
    formula.add_step {}
    assert_equal formula.count_observers, 1
    Hero::Formula.reset
    assert_equal Hero::Formula.count, 0
    assert_equal formula.count_observers, 0
  end

  describe "a registered formula" do
    it "should support adding steps" do
      Hero::Formula.register(:test_formula)
      Hero::Formula[:test_formula].add_step { }
    end

    it "should support notify" do
      Hero::Formula.register(:test_formula)
      step_ran = false
      target = Object.new
      Hero::Formula[:test_formula].add_step do |t, opts|
        assert_equal t, target
        assert_equal opts[:foo], :bar
        step_ran = true
      end
      Hero::Formula[:test_formula].notify(target, :foo => :bar)
      assert step_ran
    end

  end

end


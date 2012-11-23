require File.join(File.dirname(__FILE__), "test_helper")

class ObserverTest < MicroTest::Test
  test "should support add_step" do
    step = lambda {}
    o = Hero::Observer.new(:example)
    o.add_step(:one, step)
    assert o.steps.length == 1
    assert o.steps[0].first == :one
    assert o.steps[0].last == step
  end

  test "should support properly handle a double add" do
    step1 = lambda {}
    step2 = lambda {}
    o = Hero::Observer.new(:example)
    o.add_step(:one, step1)
    o.add_step(:one, step2)
    assert o.steps.length == 1
    assert o.steps[0].first == :one
    assert o.steps[0].last == step2
  end

  test "should properly sort steps based on the order they were added" do
    o = Hero::Observer.new(:example)
    o.add_step(:one) {}
    o.add_step(:two) {}
    o.add_step(:three) {}
    o.add_step(:four) {}
    o.add_step(:one) {}
    assert o.steps.length == 4
    assert o.steps[0].first == :two
    assert o.steps[1].first == :three
    assert o.steps[2].first == :four
    assert o.steps[3].first == :one
  end
end

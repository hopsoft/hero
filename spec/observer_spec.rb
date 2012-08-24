require "spec_helper"

describe "Hero::Observer instance" do
  include GrumpyOldMan

  it "should support add_step" do
    step = lambda {}
    o = Hero::Observer.new(:example)
    o.add_step(:one, step)
    assert_equal o.steps.length, 1
    assert_equal o.steps[0].keys.first, :one
    assert_equal o.steps[0].values.first, step
  end

  it "should support properly handle a double add" do
    step1 = lambda {}
    step2 = lambda {}
    o = Hero::Observer.new(:example)
    o.add_step(:one, step1)
    o.add_step(:one, step2)
    assert_equal o.steps.length, 1
    assert_equal o.steps[0].keys.first, :one
    assert_equal o.steps[0].values.first, step2
  end

  it "should properly sort steps based on the order they were added" do
    o = Hero::Observer.new(:example)
    o.add_step(:one) {}
    o.add_step(:two) {}
    o.add_step(:three) {}
    o.add_step(:four) {}
    o.add_step(:one) {}
    assert_equal o.steps.length, 4
    assert_equal o.steps[0].keys.first, :two
    assert_equal o.steps[1].keys.first, :three
    assert_equal o.steps[2].keys.first, :four
    assert_equal o.steps[3].keys.first, :one
  end
end

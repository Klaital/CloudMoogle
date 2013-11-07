require 'test/unit'
require_relative '../lib/CombatAccumulator'

class TestAccumulator < Test::Unit::TestCase
  def test_add_single
    a = Accumulator.new
    assert_equal(0, a.mean)

    a.add(5)
    assert_equal(5, a.mean)
    assert_equal(5, a.min)
    assert_equal(5, a.max)
    assert_equal(1, a.count)
    assert_equal(5, a.sum)

    a.add(5)
    assert_equal(5, a.mean)
    assert_equal(5, a.min)
    assert_equal(5, a.max)
    assert_equal(2, a.count)
    assert_equal(10, a.sum)

    a.add(10)
    assert_equal(6, a.mean.to_i)
    assert_equal(5, a.min)
    assert_equal(10, a.max)
    assert_equal(3, a.count)
    assert_equal(20, a.sum)
  end

  def test_add_multi
    data = [2, 4, 6] 
    a = Accumulator.new
    a.add(data)

    assert_equal(4, a.mean)
    assert_equal(6, a.max)
    assert_equal(2, a.min)
    assert_equal(3, a.count)
    assert_equal(12, a.sum)

    a = Accumulator.new(data)
    assert_equal(4, a.mean)
    assert_equal(6, a.max)
    assert_equal(2, a.min)
    assert_equal(3, a.count)
    assert_equal(12, a.sum)
  end

  def test_combat_no_type
    a = CombatAccumulator.new

    assert_equal(0, a.count)

    a.add(2)
    assert_equal(2, a.mean)
    assert_equal(2, a.min)
    assert_equal(2, a.max)
    assert_equal(1, a.count)
    assert_equal(2, a.sum)
  end
end

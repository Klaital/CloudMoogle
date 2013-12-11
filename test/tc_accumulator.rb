require 'test/unit'
require_relative '../lib/Accumulator'

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

  def test_to_xml
    # "<stats#{name_clause}><sum>#{self.sum}</sum><count>#{self.count}</count><min>#{self.min}</min><max>#{self.max}</max><mean>#{self.mean}</mean><stats>"
    a = Accumulator.new
    a.add([2,4,6])
    assert_equal("<stats><sum>12</sum><count>3</count><min>2</min><max>6</max><mean>4.0</mean><stats>", a.to_xml)
    assert_equal("<stats name=\"test\"><sum>12</sum><count>3</count><min>2</min><max>6</max><mean>4.0</mean><stats>", a.to_xml(:name => 'test'))
  end
end

require 'test/unit'
require_relative '../lib/Parser'
require_relative '../lib/Accumulator'

class TestActionAccumulator < Test::Unit::TestCase
  def setup
    @actions_melee = ['Klaital hits the Goblin Tinkerer for 8 points of damage.', 'Demandred hits the Goblin Tinkerer for 10 points of damage.'].collect do |line|
      Parser.parse_line(line)
    end
    @actions_ranged = ['Klaital\'s ranged attack hits the Goblin Tinkerer for 10 points of damage.', 'Demandred\'s ranged hits the Goblin Tinkerer for 20 points of damage.'].collect do |line|
      Parser.parse_line(line)
    end
    @acc = ActionAccumulator.new
  end

  def test_basic
    @actions_melee.each {|a| @acc.add_action(a)}
    assert_equal(@actions_melee.length, @acc.count)
    assert_equal(18, @acc.damage_total)
  end
  def test_to_xml_simple
    @acc.add_actions(@actions_melee)
    assert_equal(@actions_melee.length, @acc.count)
    assert_equal(18, @acc.damage_total)
    overall = "<stats name=\"overall\"><sum>18</sum><count>2</count><min>8</min><max>10</max><mean>9</mean><stats>"
    melee = "<stats name=\"MELEE\"><sum>18</sum><count>2</count><min>8</min><max>10</max><mean>9</mean><stats>"
    expected_xml = "<ActionStats>#{overall}#{melee}</ActionStats>"
  end

  def to_xml_multi_type
    @acc.add_actions(@actions_melee)
    @acc.add_actions(@actions_ranged)
    assert_equal(@actions_melee.length + @actions_ranged.length, @acc.count)
    assert_equal(48, @acc.damage_total)
    overall = "<stats name=\"overall\"><sum>18</sum><count>2</count><min>8</min><max>10</max><mean>9</mean><stats>"
    melee = "<stats name=\"MELEE\"><sum>18</sum><count>2</count><min>8</min><max>10</max><mean>9</mean><stats>"
    ranged = "<stats name=\"RANGED\"><sum>30</sum><count>2</count><min>10</min><max>20</max><mean>15</mean><stats>"
    expected_xml = "<ActionStats>#{overall}#{melee}#{ranged}</ActionStats>"
  end

end

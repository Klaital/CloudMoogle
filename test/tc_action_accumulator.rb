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
    @actions_ranged_pummel = ['Klaital\'s ranged attack strikes true, pummeling the Goblin Tinkerer for 10 points of damage!', 'Demandred\'s ranged attack strikes true, pummeling the Goblin Tinkerer for 18 points of damage!'].collect do |line|
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
    overall = "<stats name=\"overall\"><sum>18</sum><count>2</count><min>8</min><max>10</max><mean>9.0</mean><stats>"
    melee = "<stats name=\"HIT\"><sum>18</sum><count>2</count><min>8</min><max>10</max><mean>9.0</mean><pct_share>100.0</pct_share><stats>"
    expected_xml = "<ActionStats>#{overall}#{melee}</ActionStats>"
    assert_equal(expected_xml, @acc.to_xml)
  end

  def test_to_xml_multi_type
    @acc.add_actions(@actions_ranged_pummel)
    @acc.add_actions(@actions_ranged)
    assert_equal(@actions_ranged_pummel.length + @actions_ranged.length, @acc.count)
    assert_equal(58, @acc.damage_total)
    overall = "<stats name=\"overall\"><sum>58</sum><count>4</count><min>10</min><max>20</max><mean>14.5</mean><stats>"
    melee = "<stats name=\"HIT\"><sum>30</sum><count>2</count><min>10</min><max>20</max><mean>15.0</mean><pct_share>51.724137931034484</pct_share><stats>"
    ranged = "<stats name=\"PUMMEL\"><sum>28</sum><count>2</count><min>10</min><max>18</max><mean>14.0</mean><pct_share>48.275862068965516</pct_share><stats>"
    expected_xml = "<ActionStats>#{overall}#{melee}#{ranged}</ActionStats>"
    assert_equal(expected_xml, @acc.to_xml)
  end
end

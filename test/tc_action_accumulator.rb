require 'test/unit'
require_relative '../lib/Parser'
require_relative '../lib/Accumulator'

class TestActionAccumulator < Test::Unit::TestCase
  def setup
    @actions_melee = ['Klaital hits the Goblin Tinkerer for 8 points of damage.', 'Demandred hits the Goblin Tinkerer for 10 points of damage.'].collect do |line|
      Parser.parse_line(line)
    end
    @acc = ActionAccumulator.new
  end

  def test_basic
    @actions_melee.each {|a| @acc.add_action(a)}
    assert_equal(@actions_melee.length, @acc.count)

  end

end

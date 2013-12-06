require 'test/unit'
require_relative '../lib/Parser'

class TestParser < Test::Unit::TestCase
  def setup
    @p = Parser.new
  end
  def test_parse_simple
    a = Parser.parse_line("[14:59:01]Klaital hits the Colibri for 4 points of damage.", nil)
    assert_not_nil(a)
    assert_equal('MELEE', a.type)
    assert_equal('HIT', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('MELEE', a.ability_name)
    assert_equal('Klaital', a.actor)
    assert_equal('Colibri', a.target)
    assert_equal(4, a.damage)
  end
  
  def test_parse_crits
	a = Parser.parse_line('[18:32:27]Nimbex scores a critical hit!', nil)
	a = Parser.parse_line('[18:32:27]The Sharabha takes 136 points of damage.', a)
	assert_not_nil(a)
	assert_equal('MELEE', a.type)
    assert_equal('CRIT', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('MELEE', a.ability_name)
    assert_equal('Nimbex', a.actor)
    assert_equal('Sharabha', a.target)
    assert_equal(136, a.damage)
  end
  
  def test_parse_crits_from_file
	p = Parser.new
	p.parse_file(File.join(File.dirname(__FILE__), 'faked_test_logs', 'single_crit.log'))
	assert_equal(1, p.actions.length)
	a = p.actions[0]
	assert_not_nil(a)
	assert_equal('MELEE', a.type)
    assert_equal('CRIT', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('MELEE', a.ability_name)
    assert_equal('Drydin', a.actor)
    assert_equal('Sharabha', a.target)
    assert_equal(326, a.damage)
  end

  def test_parse_file
    @p.parse_file(File.join('faked_test_logs', 'hills1.log'))
    assert_equal(7, @p.actions.length)
  end
end


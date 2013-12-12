require 'test/unit'
require_relative '../lib/Parser'

class TestParser < Test::Unit::TestCase
  def setup
    @p = Parser.new
  end
  def test_parse_simple
    a = Parser.parse_line("[14:59:01]Klaital hits the Colibri for 4 points of damage.", nil)
    assert_not_nil(a, 'Failed to parse a simple melee hit.')
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
    assert_not_nil(a, 'Failed to parse a melee critical hit.')
    assert_equal('MELEE', a.type)
    assert_equal('CRIT', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('MELEE', a.ability_name)
    assert_equal('Nimbex', a.actor)
    assert_equal('Sharabha', a.target)
    assert_equal(136, a.damage)
    
    # Try again, but with an empty line inbetween
    a = Parser.parse_line('[18:32:27]Nimbex scores a critical hit!', nil)
    a = Parser.parse_line('', a)
    a = Parser.parse_line('[18:32:27]The Sharabha takes 136 points of damage.', a)
    assert_not_nil(a, 'Failed to parse a melee critical hit with a whitespace.')
    assert_equal('MELEE', a.type)
    assert_equal('CRIT', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('MELEE', a.ability_name)
    assert_equal('Nimbex', a.actor)
    assert_equal('Sharabha', a.target)
    assert_equal(136, a.damage)
  end
  
  def test_parse_nuke
    a = Parser.parse_line('[18:35:37]Klaital casts Dia II.')
    a = Parser.parse_line('[18:35:37]The Sharabha takes 0 points of damage.', a)
    assert_not_nil(a, 'Failed to parse Dia II being cast')
    assert_equal('SPELL', a.type)
    assert_equal('HIT', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('Dia II', a.ability_name)
    assert_equal('Klaital', a.actor)
    assert_equal('Sharabha', a.target)
    assert_equal(0, a.damage)
  end
  
  def test_parse_cure_spell
    a = Parser.parse_line('[18:35:51]Klaital casts Cure V.')
    a = Parser.parse_line('[18:35:51]Drydin recovers 719 HP.', a)
    assert_not_nil(a, 'Failed to parse Cure V being cast')
    assert_equal('SPELL', a.type)
    assert_equal('CURE', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('Cure V', a.ability_name)
    assert_equal('Klaital', a.actor)
    assert_equal('Drydin', a.target)
    assert_equal(719, a.damage)
  end
  
  def test_parse_crits_from_file
    @p.parse_file(File.join(File.dirname(__FILE__), 'faked_test_logs', 'single_crit.log'))
    assert_equal(1, @p.actions.length)
    a = @p.actions[0]
    assert_not_nil(a)
    assert_equal('MELEE', a.type)
    assert_equal('CRIT', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('MELEE', a.ability_name)
    assert_equal('Drydin', a.actor)
    assert_equal('Sharabha', a.target)
    assert_equal(326, a.damage)
  end

  def test_parse_cures_from_file
    @p.parse_file(File.join(File.dirname(__FILE__), 'faked_test_logs', 'single_cure.log'))
    assert_equal(1, @p.actions.length)
    a = @p.actions[0]
    assert_not_nil(a)
    assert_equal('SPELL', a.type)
    assert_equal('CURE', a.subtype)
    assert_equal('COMBAT', a.format)
    assert_equal('Cure V', a.ability_name)
    assert_equal('Klaital', a.actor)
    assert_equal('Drydin', a.target)
    assert_equal(719, a.damage)
  end

  def test_parse_file
  #TODO: this test seems to reliably fail when run in this script, but pass reliably when run step-by-step in IRB
    data_path = File.join(File.dirname(__FILE__),'faked_test_logs', 'hills1.log')
    assert(File.exists?(data_path), 'Required test logfile not found: #{data_path}')
    assert_equal(11, @p.parse_file(data_path))
    # 7 actions here includes: melee hits given and received by the party and one cure spell
    assert_equal(7, @p.actions.length)
  end
  
  def test_parse_big_file
    @p.parse_file(File.join(File.dirname(__FILE__),'sample_logs', 'Klaital_2011.04.04-Sharabha1.log'))
    klaital_action_count = 7 # found this by manually grepping the log, includes both Dia2 and Cure5 casts
    c = @p.actions.collect {|a| a.actor == 'Klaital' ? a : nil}.compact.length
    assert_equal(klaital_action_count, c)
  end
end


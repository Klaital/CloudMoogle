require 'test/unit'
require '../lib/PartyConfig'

class TestPartyConfig < Test::Unit::TestCase
  def test_add_member
    conf = PartyConfig.new( [ 'Klaital', 'Demandred'] )

    assert_equal(2, conf.player_characters.length)
    assert(conf.player_characters.include?('Klaital'))
    assert(conf.player_characters.include?('Demandred'))
    assert(!conf.player_characters.include?('Nimbex'))

    conf.add_player('Nimbex')
    assert_equal(3, conf.player_characters.length)
    assert(conf.player_characters.include?('Klaital'))
    assert(conf.player_characters.include?('Demandred'))
    assert(conf.player_characters.include?('Nimbex'))
  end

  def test_load
    conf = PartyConfig.load(1)

    assert_equal(0, conf.player_characters.length)
    assert_equal('test party', conf.name)
    assert_equal('2013-10-20 18:20:10', conf.start_time)
    assert_equal('2013-10-20 19:20:17', conf.end_time)
  end
end

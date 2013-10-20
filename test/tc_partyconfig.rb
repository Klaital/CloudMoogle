require 'test/unit'
require '../lib/PartyConfig'

class TestPartyConfig < Test::Unit::TestCase
  def test_add_member
    conf = PartyConfig.new( [ 'Klaital', 'Demandred'] )

    assert_equal(2, conf.player_characters.length)
    assert(conf.player_character.include('Klaital'))
    assert(conf.player_character.include('Demandred'))
    assert(!conf.player_character.include('Nimbex'))

    conf.add_player('Nimbex')
    assert_equal(3, conf.player_characters.length)
    assert(conf.player_character.include('Klaital'))
    assert(conf.player_character.include('Demandred'))
    assert(conf.player_character.include('Nimbex'))

  end
end

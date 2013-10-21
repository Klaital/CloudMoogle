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

    assert_equal(2, conf.player_characters.length)
    assert(conf.player_characters.include?('Klaital'))
    assert(conf.player_characters.include?('Demandred'))
    assert(!conf.player_characters.include?('Nimbex'))

    assert_equal('test party', conf.name)
    assert_equal('2013-10-20 18:20:10', conf.start_time)
    assert_equal('2013-10-20 19:20:17', conf.end_time)
  end

  def test_basic_save
    conf = PartyConfig.new(['Klaital', 'Demandred', 'Nimbex'])
    conf.name = "test_basic_save config"
    assert_nil(conf.id)
    conf.save

    assert_not_nil(conf.id)
    id = conf.id

    conf2 = PartyConfig.load(id)
    assert_equal(3, conf.player_characters.length)
    assert_equal("test_basic_save config", conf2.name)
    assert(conf2.player_characters.include?('Klaital'))
    assert(conf2.player_characters.include?('Demandred'))
    assert(conf2.player_characters.include?('Nimbex'))
    conf2.player_characters << 'Morlock'
    conf2.save
    assert_equal(id, conf2.id)

    conf3 = PartyConfig.load(id)
    assert_equal(4, conf3.player_characters.length)
    assert(conf3.player_characters.include?('Klaital'))
    assert(conf3.player_characters.include?('Demandred'))
    assert(conf3.player_characters.include?('Nimbex'))
    assert(conf3.player_characters.include?('Morlock'))

    conf3.delete
  end

  def test_delete
    conf = PartyConfig.new(['Klaital', 'Demandred', 'Nimbex'])
    conf.name = "test_basic_save config"
    assert_nil(conf.id)
    conf.save
    id = conf.id
    assert_not_nil(conf.id)
    conf.delete

    assert_nil(conf.id)
    conf2 = PartyConfig.load(id)
    assert(!conf2)
  end
end

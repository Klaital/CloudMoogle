require 'test/unit'
require 'time'
require_relative '../lib/configs'
require_relative '../lib/Parser'
require_relative '../lib/Analyzer'

class TestAnalyzer < Test::Unit::TestCase
  def setup
    @sharabha_parse = Parser.new
    @sharabha_parse.parse_file(File.join(File.dirname(__FILE__), 'faked_test_logs', 'sharabha1.log'))
    @a = Analyzer.new
    @sharabha_party = PartyConfig.new
    @sharabha_party.player_characters = ['Klaital','Kireila', 'Demandred', 'Drydin', 'Nimbex', 'Morlock']
    @sharabha_party.start_time = Time.parse('2011-04-04T18:32:00')
    @sharabha_party.end_time   = Time.parse('2011-04-04T19:32:00')
  end
  
  def test_player_analysis
    assert_not_nil(@sharabha_parse)
    assert(@sharabha_parse.actions.length > 0, "No actions parsed for Sharabha run")
    assert(@sharabha_party.player_characters.length, "No party members found for Sharabha run")
    data = @a.analyze_by_players(@sharabha_parse.actions, @sharabha_party.player_characters)
    assert(data.kind_of?(Hash), "#analyze_by_players did not return a data hash!")
    assert_equal(2, data['Klaital'][:damage_dealt_total])
    assert_equal(480, data['Nimbex'][:damage_dealt_total])
    assert_equal(326, data['Drydin'][:damage_dealt_total])
    assert_equal(83.3, data['Nimbex'][:hitrates]['MELEE'].round(1))
    assert_equal(100.0, data['Drydin'][:hitrates]['MELEE'])
    assert_equal(0.0, data['Klaital'][:hitrates]['MELEE'])
  end
end

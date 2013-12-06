require 'test/unit'
require 'time'
require_relative '../lib/configs'
require_relative '../lib/Parser'
require_relative '../lib/Analyzer'

class TestAnalyzer < Test::Unit::TestCase
  def setup
    @p = Parser.new
    @p.parse_file(File.join(File.dirname(__FILE__), 'faked_test_logs', 'sharabha1.log'))
    @a = Analyzer.new
    @party = PartyConfig.new(['Klaital','Kireila', 'Demandred', 'Drydin', 'Nimbex', 'Morlock'], Time.parse('2011-04-04T18:32:00'), Time.parse('2011-04-04T19:32:00'))
  end
  def test_data_upload
    data = "<analysis><data>foo</data></analysis>"
    filename = "test-data.xml"

    a = Analyzer.new
    a.upload_analysis(filename, data)

    bucket = CONFIGS[:aws][:s3][:analysis_bucket]
    s3 = AWS::S3.new
    b = s3.buckets[bucket]
    check_data = b.objects[filename].read
    assert_equal(data,check_data)

    # Cleanup
    b.objects[filename].delete
  end

  def test_player_analysis
    data = @a.analyze_by_players(@p.actions, @party.player_characters)
    assert(data.kind_of?(Hash), "#analyze_by_players did not return a data hash!")
    assert_equal(2, data['Klaital'][:damage_dealt_total])
    assert_equal(480, data['Nimbex'][:damage_dealt_total])
    assert_equal(326, data['Drydin'][:damage_dealt_total])
    assert_equal(83.3, data['Nimbex'][:hitrates]['MELEE'].round(1))
    assert_equal(100.0, data['Drydin'][:hitrates]['MELEE'])
    assert_equal(0.0, data['Klaital'][:hitrates]['MELEE'])
  end
end

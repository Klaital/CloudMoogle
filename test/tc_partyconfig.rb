require 'test/unit'
require_relative '../lib/PartyConfig'

class TestPartyConfig < Test::Unit::TestCase
  def setup
    @db = AWS::DynamoDB.new
    @table = @db.tables['cloudmoogle-parties']
    @table.hash_key = [:party_id, :string]
    @config_id1 = 'bae0f118-798d-40d5-a66d-dda40e9eddd6'
  end
  def test_read_party
    # I created this one manually
    item = @table.items["bae0f118-798d-40d5-a66d-dda40e9eddd6"]
    assert(item.exists?)
    attribs = item.attributes
    assert_equal('Test Party (manual)', attribs['name'])
    assert_equal('2011-04-04T18:36:14-07:00', attribs['end_time'])
    assert_equal('2011-04-04T18:32:09-07:00', attribs['start_time'])
    pcs = attribs['player_characters']
    assert_not_nil(pcs)
    assert(pcs.kind_of?(Set), "player_characters not of the expected type: Expected 'Set'")
    pcs = pcs.to_a
    assert_equal(6, pcs.size)
    expected_pcs = ['Klaital', 'Nimbex', 'Morlock', 'Drydin', 'Kireila']
    expected_pcs.each do |pc|
      assert(pcs.include?(pc), "Expceted PC not found: #{pc}")
    end
  end
  def test_create_new_party
    new_id = "41550abe-a207-4cca-893c-24cf418f7ebb"
    if(@table.items[new_id].exists?)
      @table.items[new_id].delete
    end
    item = @table.items.create('party_id' => '41550abe-a207-4cca-893c-24cf418f7ebb', 'player_characters' => ['Klaital', 'Demandred'], 'name' => 'Test::Unit Party')
    assert(item.exists?, 'Item not successfully created.')
    item.delete
    assert(!item.exists?, 'Item not successfully deleted.')
  end
  def test_save_and_load
    # Load a premade config from the DB, and verify
    config1 = PartyConfig.new(@config_id1)
    assert_equal(5, config1.player_characters.length)
    assert(config1.player_characters.include?('Morlock'), 'Config does not seem to have the correct party members')
    assert_equal('Test Party (manual)', config1.name)
    assert_equal('2011-04-04T18:36:14-07:00', config1.end_time.iso8601)
    assert_equal('2011-04-04T18:32:09-07:00', config1.start_time.iso8601)
    assert_nil(config1.logfile)
    
    # Save the config back with a change
    config1.logfile = '/dev/null'
    config1.save
    
    # Re-read the config and verify the change
    config2 = PartyConfig.new(@config_id)
    assert_equal('/dev/null', config2.logfile)
    
    # Change a value again, then save as a new config
    config2.logfile = '/home/nobody/ffxi.log'
    config2.save_new_copy
    # Verify that the ID has changed
    assert_not_equal(config1.id, config2.id)
    
    # Re-read the config again, and verify the change
    config3 = PartyConfig.new(config2.id)
    assert_equal('/home/nobody/ffxi.log', config3.logfile)
    assert_equal('Test Party (manual)', config3.name)
    assert_equal('2011-04-04T18:36:14-07:00', config3.end_time.iso8601)
    assert_equal('2011-04-04T18:32:09-07:00', config3.start_time.iso8601)
    
    # Cleanup the first config
    config1.logfile = nil
    config1.save
    # Reread and verify
    config3 = PartyConfig.new(config1.id)
    assert_nil(config3.logfile)
    
    # Delete the extra config we created
    config2.delete
  end
end

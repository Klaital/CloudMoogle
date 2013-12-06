require 'securerandom'
require 'time' # adds utility methods to Time, such as Time#iso8601
require_relative '../lib/configs'

class PartyConfig
  attr_accessor :id

  attr_accessor :player_characters
  attr_accessor :name, :start_time, :end_time

  def initialize(player_characters=[], start_time=Time.now, end_time=Time.now + (60*60*12))
    @id = nil
    @player_characters = player_characters
    @start_time = start_time
    @end_time = end_time
    @name = ''
  end

  # Add a new member to the party without allowing duplicates.
  def add_player(new_party_member)
    @player_characters << new_party_member unless(@player_characters.include?(new_party_member))
  end

  # Read the Party Configuration data from the database
  # @param id [String] The GUID PartyId key value as stored in the database.
  # @return [Boolean] false if the id is invalid or not found in the database, true if successfully loaded.
  def load(id)
    # Read the configuration from DynamoDB 
    db = AWS::DynamoDB.new
    table = db.tables[CONFIGS[:db][:party_configs][:table]]
    table.hash_key = [:party_id, :string]
    item = table.items[id]
    return false if (!item.exists?)
    item = item.attributes

    @id = item['party_id']
    @start_time = item['start_time']
    @end_time = item['end_time']
    @name = item['name']
    @player_characters = item['player_characters']
    @player_characters = if (@player_characters.nil?) 
      []
    else
      # The DynamoDB return is actually a Set, not an Array, so convert now.
      @player_characters.to_a
    end
    
    return true
  end

  # Save the Party Configuration data back out to the database
  def save
    @id = @id.nil? ? SecureRandom.uuid : @id.to_s
    table = AWS::DynamoDB.new.tables[CONFIGS[:db][:party_configs][:table]]
    table.hash_key = [:party_id, :string]
    return false unless(table.exists?)
    table.items.create('party_id' => @id, 'start_time' => @start_time.iso8601, 'end_time' => @end_time.iso8601, 'player_characters' => @player_characters, 'name' => @name)
  end

  # Delete the party configuration data from the database
  def delete
    # Read the configuration from DynamoDB 
    db = AWS::DynamoDB.new
    table = db.tables[CONFIGS[:db][:party_configs][:table]]
    table.hash_key = [:party_id, :string]
    item = table.items[id]
    return false if (!item.exists?)
    item.delete
    return true
  end
end


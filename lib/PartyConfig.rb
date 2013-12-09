require 'securerandom'
require 'time' # adds utility methods to Time, such as Time#iso8601
require_relative '../lib/configs'

class PartyConfig
  attr_accessor :id

  attr_accessor :player_characters
  attr_accessor :name, :start_time, :end_time
  attr_accessor :stats
  attr_accessor :logfile

  def initialize(party_id=nil)
    @id = party_id
    @player_characters = []
    @start_time = Time.now
    @end_time = Time.now + (60*60*12)
    @name = ''
    @logfile = nil
    @stats = {}
    self.load(@id) unless(@id.nil?)
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
    @logfile = item['logfile']
    @player_characters = item['player_characters']
    @player_characters = if (@player_characters.nil?) 
      []
    else
      # The DynamoDB return is actually a Set, not an Array, so convert now.
      @player_characters.to_a
    end
    
    return true
  end
  
  def PartyConfig.load(id)
    pc = PartyConfig.new
    pc.load(id)
    return pc
  end

  # Save the Party Configuration data back out to the database
  def save
    @id = @id.nil? ? SecureRandom.uuid : @id.to_s
    table = AWS::DynamoDB.new.tables[CONFIGS[:db][:party_configs][:table]]
    table.hash_key = [:party_id, :string]
    return false unless(table.exists?)
    item = table.items[@id]
    if (item.exists?)
      item.attributes.update do |i|
        i.set(:start_time => @start_time.iso8601)
        i.set(:end_time => @end_time.iso8601)
        i.set(:player_characters => @player_characters)
        i.set(:logfile => @logfile)
        i.set(:name => @name)
        i.set(:stats => @stats)
      end
    else
      table.items.create('party_id' => @id, 'logfile' => @logfile, 'start_time' => @start_time.iso8601, 'end_time' => @end_time.iso8601, 'player_characters' => @player_characters, 'name' => @name)
    end
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


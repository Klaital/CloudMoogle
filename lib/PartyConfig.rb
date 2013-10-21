require '../lib/configs'

class PartyConfig
  attr_accessor :id

  attr_accessor :player_characters
  attr_accessor :name, :start_time, :end_time

  def initialize(player_characters=['Klaital', 'Demandred'], start_time=Time.now, end_time=Time.now + (60*60*12))
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
  def PartyConfig.load(id)
    return false unless(id.kind_of?(Fixnum))
    p = PartyConfig.new
    p.id = id

    res = PARTY_CONFIG_MYSQL.query("SELECT * party_configs WHERE party_config.id = #{id}")
    return false if (res.nil? || res.length == 0)
    row = res.fetch_row
    return false if (row.nil? || row.length < 4)
    p.start_time = row['start_time']
    p.end_time = row['end_time']
    p.name = row['name']

    return p
  end

  # Save the Party Configuration data back out to the database
  def save
    # TODO: implement actual database-writing logic here
    id = @id.nil? ? 'NULL' : @id.to_s
    res = PARTY_CONFIG_MYSQL.query("INSERT INTO party_configs VALUES (#{id},'#{@name}','#{@start_time}', '#{@end_time}') ON DUPLICATE KEY UPDATE")
    return res.nil?
  end
end


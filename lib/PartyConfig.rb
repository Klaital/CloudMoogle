require '../lib/configs'

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
  def PartyConfig.load(id)
    return false unless(id.kind_of?(Fixnum))
    p = PartyConfig.new
    p.id = id

    res = PARTY_CONFIG_MYSQL.query("SELECT * FROM party_configs WHERE party_configs.party_id = #{id}")
    return false if (res.nil?)
    row = res.fetch_row
    return false if (row.nil? || row.length < 4)
    p.name = row[1]
    p.start_time = row[2]
    p.end_time = row[3]

    # Load the party members, too
    res = PARTY_CONFIG_MYSQL.query("SELECT * FROM party_members WHERE party_members.party_id = #{id}")
    unless(res.nil?)
      res.each do |row|
        p.player_characters << row[2]
      end
    end

    return p
  end

  # Save the Party Configuration data back out to the database
  def save
    id = @id.nil? ? 'NULL' : @id.to_s
    res = PARTY_CONFIG_MYSQL.query("INSERT INTO party_configs VALUES (#{id},'#{PARTY_CONFIG_MYSQL.escape_string(@name)}','#{PARTY_CONFIG_MYSQL.escape_string(@start_time.to_s)}', '#{PARTY_CONFIG_MYSQL.escape_string(@end_time.to_s)}') ON DUPLICATE KEY UPDATE party_id=LAST_INSERT_ID(party_id)")
    @id = PARTY_CONFIG_MYSQL.insert_id
    # Update the party members
    res = PARTY_CONFIG_MYSQL.query("DELETE FROM party_members WHERE party_id = #{@id}")
    q = "INSERT INTO party_members VALUES" + @player_characters.collect {|pc| "(NULL, #{@id}, '#{PARTY_CONFIG_MYSQL.escape_string(pc)}')"}.join(',')
    res = PARTY_CONFIG_MYSQL.query(q)
  end

  # Delete the party configuration data from the database
  def delete
    return false if (@id.nil? || !@id.kind_of?(Fixnum))
    PARTY_CONFIG_MYSQL.query("DELETE FROM party_configs WHERE party_id = #{@id}")
    PARTY_CONFIG_MYSQL.query("DELETE FROM party_members WHERE party_id = #{@id}")
    @id = nil
  end
end


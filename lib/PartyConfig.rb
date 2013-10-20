
class PartyConfig
  attr_reader :id

  attr_accessor :player_characters
  attr_accessor :start_time
  attr_accessor :end_time

  def initialize(player_characters=['Klaital', 'Demandred'], start_time=Time.now, end_time=Time.now + (60*60*12))
    @player_characters = player_characters
    @start_time = start_time
    @end_time = end_time
  end

  # Add a new member to the party without allowing duplicates.
  def add_player(new_party_member)
    @player_characters << new_party_member unless(@player_characters.include?(new_party_member))
  end

  # Read the Party Configuration data from the database
  def PartyConfig.load(id)
    # TODO: choose a database, implement actual read logic here
    p = PartyConfig.new
  end

  # Save the Party Configuration data back out to the database
  def save
    # TODO: implement actual database-writing logic here
    return false
  end
end


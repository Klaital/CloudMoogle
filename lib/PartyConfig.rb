
class PartyConfig
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
        @player_characters << new_party_memeber unless(@player_characters.include?(new_party_member)
    end
end


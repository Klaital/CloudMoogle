#!/usr/bin/env ruby
require 'time'
require_relative '../lib/PartyConfig'

# TODO: add copy command
# TODO: add some filtering for list command
def usage(subcmd=nil)
  helpstr = {}
  helpstr['new'] = <<NEW_USAGE
> ruby #{$0} new [-n PARTY_NAME] [-s START_TIME] [-e END_TIME] PLAYER1 [[PLAYER2] ... [PLAYER_N]]
Create a new PartyConfig using the specified set of Player Characters, and optionally the name, start time and end time.
  -n, --name PARTY_NAME  -- Use the given name as the party descriptor. Essentially freetext to help you find it in a list. Will default to "PLAYER1's party".
  -s, --start START_TIME -- Specify the starting timestamp. Should just be HH:mm:ss, as that's all the info contained in the timestamps added by the Windower Timestamp plugin.
  -e, --end END_TIME     -- Just like START_TIME, but used to specify the ending time. These two values are mostly useful for after-action parses, if you want to focus on analysis of a specific battle, such as a particular BCNM run on a day when you did many other things as well. Maybe an Abyssea XP party spammed up the logfile after the BC run?
  PLAYER1 ... PLAYER_N   -- Specify as many Player Character names as you want the parser to consider as "with you". Anyone else will be ignored, even if they were officially in your party/alliance. Non-alliance members can be included, if you want. Make sure your in-game filters are allowing the data you want to pass into the log!
                            NOTE: at least one player is required for a party to exist!
NEW_USAGE
  helpstr['list'] = <<LIST_USAGE
> ruby #{$0} list
Generate a list describing all of your party configs.
LIST_USAGE
  helpstr['delete'] = <<DEL_USAGE
> ruby #{$0} delete PARTY_ID
Delete a Party Configuration from your database.
DEL_USAGE

  s = ''
  if (subcmd.nil? || !helpstr.keys.include?(subcmd))
    helpstr.each_pair do |cmd, usage|
      s += usage + "\n"
    end
  else
    s += helpstr[subcmd]
  end
  
  return s
end


def list_parties
  table = AWS::DynamoDB.new.tables[CONFIGS[:db][:party_configs][:table]]
  table.hash_key = [:party_id, :string]
  return false unless(table.exists?)
  
  table.items.each do |item|
    puts "================================================"
    puts "PartyId=#{item.attributes['party_id']}"
    puts "PartyName=#{item.attributes['name']}"
    puts "StartTime=#{item.attributes['start_time']}"
    puts "EndTime=#{item.attributes['end_time']}"
    puts "Logfile=#{item.attributes['logfile']}"
    pcs = (item.attributes['player_characters'].nil?) ? [] : item.attributes['player_characters'].to_a
    pcs.each_index do |pc_i|
      puts "Player.#{pc_i}=#{pcs[pc_i+1]}"
    end
  end
end


##############
#### MAIN ####
##############
if (ARGV.length == 0 || ARGV.include?('-h') || ARGV[0] == 'help')
  puts usage
  exit 1
end

case(ARGV[0])
when 'list'
  list_parties
when 'delete'
  if (ARGV.length < 2) 
    puts usage('delete')
    exit 2
  end
  party = PartyConfig.load(ARGV[-1])
  party.delete if(party)
when 'new'
  party = PartyConfig.new
  args = ARGV[1..-1] # Discard the action
  party.name = parse_arg(args, ['-n','--name'], true, "Default partyname", true)
  party.start_time = parse_arg(args, ['-s', '--start'], true, Time.now, true)
  party.start_time = parse_arg(args, ['-e', '--end'], true, (Time.now + (3600*12)), true)
  party.logfile = parse_arg(args, ['-l','--log'], true, nil, true)
  if (args.empty?)
    # Try to read the party list from standard input
    while(s=$stdin.gets)
      args << s.strip 
    end
  end
  
  # If there are still no party members, abord with an error
  if (args.empty?)
    puts "Error! The party cannot be empty!"
    puts usage('new')
    exit 1
  end
    
  party.player_characters = args
  party.save
  puts party.inspect
when 'copy'
  party = PartyConfig.load(ARGV[-1])
  party.save_new_copy
  puts party.inspect
else
  puts usage
  exit 1
end

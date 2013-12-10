#!/usr/bin/env ruby
require 'file-tail'
require_relative '../lib/PartyConfig'
require_relative '../lib/Manager'


def usage
  s = <<USAGE
Continuously update the analysis for a game in progress. You'll need the PATH 
to the FFXI logfile and the GUID that identifies your PartyConfig in the DB.
(see bin/parties.rb if you don't have/know a party ID)
> ruby #{__FILE__} [-d SECS] <FFXI_LOGFILE_PATH> <PARTY_ID>
USAGE
end

if (ARGV.length < 2)
  puts usage
  exit 1
end
seconds_between_analyses = parse_arg(ARGV, ['-d','--delay'], false, 120)
party_id = ARGV[-1]
log_path = ARGV[-2]

if (!File.exists?(log_path))
  puts "ERROR Logfile not found: #{log_path}"
  puts usage
  exit 1
end


manager = Manager.new(party_id)
manager.sleep_interval = seconds_between_analyses
puts "Starting the parser... hit Ctrl+C when you're done playing."
manager.run!(File::Tail::Logfile.new(log_path))

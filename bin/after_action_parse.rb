# Used to re-parse a logfile after it's been closed. This is useful for generating a final after-action report
# for debriefing the party. 
# 
# Usage: ruby after_action_parse.rb PATH_TO_LOGFILE

require_relative '../lib/Parser'
unless (ARGV.length > 0 && File.exist?(ARGV[0]))
    puts "Please specify the logfile to parse"
    puts "Usage: ruby after_action_parse.rb PATH_TO_LOGFILE"
    exit
end

p = Parser.new
p.parse_file(ARGV[0])
puts "#{p.actions.length} actions parsed"


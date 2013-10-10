# Used to re-parse a logfile after it's been closed. This is useful for generating a final after-action report
# for debriefing the party. 
# 
# Usage: ruby after_action_parse.rb PATH_TO_LOGFILE

$: << "../src"

require 'Parser2'
unless (ARGV.length > 0 && File.exist?(ARGV[0]))
    puts "Please specify the logfile to parse"
    puts "Usage: ruby after_action_parse.rb PATH_TO_LOGFILE"
    exit
end

@in = File.open(ARGV[0], 'r')

p = Parser.new
p.output_mode = 'json'
p.start(@in, $stdout)
@in.close


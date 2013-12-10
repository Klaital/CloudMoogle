# Used to re-parse a logfile after it's been closed. This is useful for generating a final after-action report
# for debriefing the party. 
# 
# Usage: ruby after_action_parse.rb -l PATH_TO_LOGFILE [-p PARTY_ID]

require_relative '../lib/Manager.rb'

def usage
  s = <<USAGE
> ruby #{__FILE__} -l PATH_TO_LOGFILE [-p PARTY_ID] [-s SLEEP_SECS]
USAGE

  return s
end
party_id = parse_arg(ARGV, ['-p','--party'], true, 'bae0f118-798d-40d5-a66d-dda40e9eddd6')
log_path = parse_arg(ARGV, ['-l','--logfile'], true, nil)
sleep_interval = parse_arg(ARGV, ['-s', '--sleep'], true, 10)

if (log_path.nil? || !File.exists?(log_path))
  puts usage
  exit 1
end

m = Manager.new(party_id)
m.sleep_interval = sleep_interval
File.open(log_path, 'r') do |f|
  m.run!(f)
end

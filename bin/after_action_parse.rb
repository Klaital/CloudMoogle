# Used to re-parse a logfile after it's been closed. This is useful for generating a final after-action report
# for debriefing the party. 
# 
# Usage: ruby after_action_parse.rb PATH_TO_LOGFILE

require_relative '../lib/Manager.rb'

party_id = (ARGV.length < 1) ? 'bae0f118-798d-40d5-a66d-dda40e9eddd6' : ARGV[-1] 
m = Manager.new(party_id)
m.sleep_interval = 10
path = File.join(File.dirname(__FILE__), 'sample_logs', 'Klaital_2011.04.04-Sharabha1.log')
m.run!(path)

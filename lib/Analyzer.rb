require 'aws-sdk'
require_relative '../lib/configs'
require_relative '../lib/PartyConfig'

class Analyzer
  attr_accessor :party_id
  attr_reader :actions
  attr_reader :accumulators

  def initialize(party_id=nil)
    @party_id = party_id
    @actions = []
    @accumulators = {
      :melee => Accumulator.new('Melee')
      :magic => Accumulator.new('Magic')
      :ja => Accumulator.new('Job Abilities')
      :weaponskill => Accumulator.new('Weaponskills')
    }
  end

  def analyze_offense
    return false if (@party_id.nil?)
    @party_config = PartyConfig.load(@party_id)
    if (@party_config.nil?)
      LOGGER.debug {"Unable to load party configuration for id #{@party_id}"}
      return false
    end

    @actions = fetch_actions # Pull the set of Actions performed by this party from the data store (probably a mongodb or dynamodb somewhere)

    # TODO: maths!

    # TODO: format the data into XML or something
    output_data = 'test output: ' + Time.now.utc

    # Write the results to S3
    output_filename = "#{@party_id}.offense.xml"
    upload_analysis(output_filename, output_data)
  end

  def fetch_actions
    PARTY_CONFIG_MYSQL.query("SELECT * FROM actions WHERE party_id = #{PARTY_CONFIG_MYSQL.escape_string(@party_id.to_s)}") do |res|
      # TODO: finish loading the set of actions
      res.each do |row|
        add_action(row)
      end
    end
  end

  def add_action(row)
    # TODO: update any relevant accumulators
    @actions << row
    dmg = row[6]
    actor = row[1]

    if (!dmg.nil? && @party_config.player_characters.include?(actor))  # COMBAT type row
      case (row[3])
      when 'MELEE'
        @accumulators[:melee].add_datum(dmg) 
      when 'WS'
        @accumulators[:weaponskill].add_datum(dmg)
      when 'MAGIC'
        @accumulators[:magic].add_datum(dmg)
      when 'JA'
        @accumulators[:ja].add_datum(dmg)
      end
    end
  end

  def upload_analysis(filename, data)
    bucket = CONFIGS[:aws][:s3][:analysis_bucket]
    s3 = AWS::S3.new
    LOGGER.d("Writing analysis: Bucket '#{bucket}', Filename '#{filename}', Data Length #{data.length}")
    b = s3.buckets[bucket]
    o = b.objects[filename]
    o.write(data)
  end
end



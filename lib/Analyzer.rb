require 'aws-sdk'
require_relative '../lib/configs'
require_relative '../lib/PartyConfig'

class Analyzer
  attr_accessor :party_id
  attr_reader :actions
  def initialize(party_id=nil)
    @party_id = party_id
    @actions = []
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
    res = PARTY_CONFIG_MYSQL.query("SELECT * FROM actions WHERE party_id = #{PARTY_CONFIG_MYSQL.escape_string(@party_id.to_s)}")
    # TODO: finish loading the set of actions
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

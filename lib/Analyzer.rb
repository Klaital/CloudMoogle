require 'aws-sdk'
require '../lib/configs'
require '../lib/PartyConfig'

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

  def upload_analysis(filename, data)
    AWS.config({:access_key_id => CREDS[:aws][:access], :secret_access_key => CREDS[:aws][:secret]})
    LOGGER.d("AWS Configured with " + CREDS[:aws][:access] + " and " + CREDS[:aws][:secret])
    bucket = CONFIGS[:aws][:s3][:analysis_bucket]
    s3 = AWS::S3.new
    LOGGER.d("Attempting S3 connection: " + s3.config)
    LOGGER.d("Writing analysis: Bucket '#{bucket}', Filename '#{filename}', Data Length #{data.length}")
    b = s3.buckets[bucket]
    LOGGER.d("Got bucket: " + b.to_s)
    o = b.objects[filename]
    LOGGER.d("Got object: " + o.to_s)
    o.write(data)
  end
end

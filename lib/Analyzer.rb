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
    @party_config = PartyConfig.new(@party_id)

    @actions = fetch_actions # Pull the set of Actions performed by this party from the data store (probably a mongodb or dynamodb somewhere)

    # TODO: maths!

    # TODO: format the data into XML or something
    output_data = 'test output: ' + Time.now.utc

    # Write the results to S3
    output_filename = "#{@party_id}.offense.xml"
    # TODO: add actual S3 upload logic
  end


end

require_relative '../lib/Manager'
require_relative '../lib/configs'
require 'aws-sdk'
require 'test/unit'

class TestManager < Test::Unit::TestCase
  def testRequestAnalysis
    # I created this one manually
    id ="bae0f118-798d-40d5-a66d-dda40e9eddd6"
    party = PartyConfig.new
    party.load(id)
    m = Manager.new
    m.party = party

    queue = CONFIGS[:aws][:sqs][:queue]
    sqs = AWS::SQS.new
    q = sqs.queues['queue']
    # Check the length of the queue

    begin
      q = sqs.queues.create(queue)
    rescue AWS::SQS::Errors::InvalidParameterValue => e
      exit(1)
    end
    assert_equal(0, q.approximate_number_of_messages)

    # Request the analysis
    m.request_analysis
    msg = q.receive_message
    assert_equal("<AnalysisRequest><PartyId>#{id}</PartyId></AnalysisRequest>", msg.body)
    msg.delete
  end
end

require_relative '../lib/Manager'
require_relative '../lib/configs'
require 'aws-sdk'
require 'test/unit'

class TestManager < Test::Unit::TestCase
  def testRequestAnalysis
    party = PartyConfig.load(1)
    m = Manager.new
    m.party = party

    queue = CONFIGS[:aws][:sqs][:queue]
    sqs = AWS::SQS.new
    q = sqs.queues['queue']
    # Check the length of the queue
    unless(q.exists?)
      @logger.i ("Creating queue: #{queue}")
      begin
        q = sqs.queues.create(queue)
      rescue AWS::SQS::Errors::InvalidParameterValue => e
        @logger.f ("Invalid queue name '#{queue}'. Aborting!")
        exit(1)
      end
    end
    # assert_equal(0, q.approximate_number_of_messages)

    # Request the analysis
    m.request_analysis
    msg = q.receive_message
    assert_equal('Analysis, please! PartyId=1', msg.body)
    msg.delete
  end
end

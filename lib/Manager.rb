require_relative '../lib/PartyConfig'
require_relative '../lib/configs'
require_relative '../lib/Analyzer'

class Manager
  attr_accessor :party

  def initialize
    @party = PartyConfig.new
    @logger = Logger.new(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'logs', 'manager.log'), 'daily')
  end

  def request_analysis
    queue = CONFIGS[:aws][:sqs][:queue]
    @logger.d("Requesting analysis via SQS queue #{queue}.")
    sqs = AWS::SQS.new

    q = sqs.queues['queue']
    unless(q.exists?)
      @logger.i ("Creating queue: #{queue}")
      begin
        q = sqs.queues.create(queue)
      rescue AWS::SQS::Errors::InvalidParameterValue => e
        @logger.f ("Invalid queue name '#{queue}'. Aborting!")
        exit(1)
      end
    end

    # Actually send the message
    m = q.send_message("Analysis, please! PartyId=#{@party.id}")
    @logger.d ("Message sent, MessageId=#{m.id}")
  end

  def run!
    analyzer = Analyzer.new
    
  end
end

require_relative '../lib/PartyConfig'
require_relative '../lib/configs'
require_relative '../lib/Parser'

class Manager
  attr_accessor :party
  attr_accessor :sleep_interval

  def initialize(party_id=nil)
    @party = PartyConfig.new(party_id)
    @logger = Logger.new(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'logs', 'manager.log'), 'daily')
    @sleep_interval = 5 * 3600
    
  end
  
  def probable_output_url
    b = AWS::S3.new.buckets[CONFIGS[:aws][:s3][:analysis_bucket]]
    probable_output_url = b.objects["#{@party.id}.html"].url_for(:read)
  end

  def upload_action_data(data)
    @logger.i {"Uploading action data for party #{@party.id}; #{data.length} actions to be written."}
    bucket = AWS::S3.new.buckets[CONFIGS[:aws][:s3][:data_bucket]]
    if (bucket.nil? || !bucket.exists?)
      return false  
    end

    obj = bucket.objects["#{@party.id}.data"]
    str = (data.kind_of?(Array)) ? data.reverse.collect {|x| x.to_s}.join("\n") : data.to_s
    obj.write( str )
    @logger.d {"#{str.length} characters written"}
    return obj.etag
  end

  def request_analysis
    queue = CONFIGS[:aws][:sqs][:queue]
    @logger.d {"Requesting analysis via SQS queue #{queue}."}
    sqs = AWS::SQS.new

    q = sqs.queues.create(queue)
    unless(q.exists?)
      @logger.i {"Creating queue: #{queue}"}
      begin
        q = sqs.queues.create(queue)
      rescue AWS::SQS::Errors::InvalidParameterValue => e
        @logger.f {"Invalid queue name '#{queue}'. Aborting!"}
        exit(1)
      end
    end

    # Actually send the message
    m = q.send_message("#{@party.id}")
    @logger.d {"Message sent, MessageId=#{m.id}"}
  end

  def run!(ffxi_logfile)
    parser = Parser.new
    # Let the parser run in a separate thread; we'll just query its actions array every few minutes.
    parser_thread = Thread.new {parser.parse_stream(ffxi_logfile)}

    # Spawn a timer thread; every so often upload the actions to S3 and request the Analyzer to run on it.
    last_upload_count = 0 # Number of actions uploaded last
    begin
      puts "Sleeping while the parser runs..."
      puts "Expect the report to eventually show up here: #{self.probable_output_url}"
      
      sleep (@sleep_interval)

      # If there's data to work on in the parser, then let's upload them
      lines_to_process = parser.actions.length
      last_upload_count = upload_action_data(parser.actions)
      puts "Expect the report to eventually show up here: #{@probable_output_url}"
      self.request_analysis

    rescue Exception => e
      puts "Quitting: #{e}"
    end

    # If more data has been parsed, upload the data one last time and request a final analysis 
    unless(last_upload_count == parser.actions.length)
      upload_action_data(parser.actions) 
      self.request_analysis
      puts "Expect the report to eventually show up here: #{self.probable_output_url}"
    end

    # Signal the parser to quit, then cleanup any resources
    parser.stop=true
    parser_thread.join
  end
end

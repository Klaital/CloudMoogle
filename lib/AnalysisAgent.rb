require 'tempfile'
require_relative '../lib/PartyConfig'
require_relative '../lib/configs'
require_relative '../lib/Analyzer'
require_relative '../lib/CharacterAnalysisFormatter'

class ProcessingError < StandardError; end;

class AnalysisAgent
  def initialize(queue_name = CONFIGS[:aws][:sqs][:queue], \
                  actions_bucket = CONFIGS[:aws][:s3][:data_bucket], \
                  analysis_bucket = CONFIGS[:aws][:s3][:analysis_bucket])
    @queue = AWS::SQS.new.queues.create(queue_name)
    @actions_bucket = actions_bucket
    @analysis_bucket = analysis_bucket
  end
  
  def poll!
    loop do
      @queue.poll do |msg|
        metrics = {
          :start_time => Time.now,
          :end_time => nil,
          :processing_end_time => nil,
          :status => 'none',
          :msg_id => msg.id,
          :input_length => msg.body.length
        }
        f = nil
        begin
          # Validate the message: it should just be a guid.
          raise ProcessingError, 'guid_not_found' unless (msg.body =~ /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/)
          
          # Load the PartyConfig from the database.
          LOGGER.d {"Loading PartyConfig from DB for ID #{msg.body}"}
          pc = PartyConfig.new
          raise ProcessingError, 'party_not_found' unless (pc.load(msg.body))
          
          # Load the Action Set from S3.
          LOGGER.d {"Loading ActionData from S3: #{msg.body}.data"}
          s3 = AWS::S3.new
          bucket = s3.buckets[@actions_bucket]
          unless(bucket.exists?)
            LOGGER.i {"creating actions bucket: '#{@actions_bucket}'"}
            s3.buckets.create(:name => @actions_bucket) 
            sleep(1) until(bucket.exists?)
          end
          obj = bucket.objects["#{msg.body}.data"]
          raise ProcessingError, 's3_data_not_found' unless(obj.exists?)
          
          # Stream the actions data to a tempfile.
          f = Tempfile.new(@actions_bucket)
          obj.read {|chunk| f.write(chunk)}
          
          # Read the data back, parsing it into an array of Action objects.
          f.rewind
          actions = []
          f.each_line do |line|
            actions.unshift(Action.parse_tsv(line))
          end
          actions.compact!
          
          # Hand the Action set to an Analyzer to compute the battle statistics.
          analyzer = Analyzer.new
          stats = analyzer.analyze_by_players(actions, pc.player_characters)
          # Woo, processing complete
          metrics[:processing_end_time] = Time.now
          
          # Save the analysis in the Party's database document
          pc.stats = stats
          pc.save
          
          # Use an Analysis Formatter to generate a human-readable report
          formatter = CharacterAnalysisFormatter.new(stats)
          # Write the report back to S3
          bucket = AWS::S3.new.buckets[@analysis_bucket]
          unless(bucket.exists?)
            LOGGER.i {"creating analysis bucket: '#{@analysis_bucket}'"}
            s3.buckets.create(:name => @analysis_bucket)
            sleep(1) until(bucket.exists?)
          end
          obj = bucket.objects["#{pc.id}.html"]
          obj.delete if (obj.exists?)
          obj.write(formatter.report) # formatter.report is where the actual HTML generation occurs
          
          metrics[:status] = 'success'
          
        rescue ProcessingError => e
          metrics[:status] = e.message
        ensure
          # Remove the tempfile that was used to hold the actions data
          if (!f.nil? && File.exists?(f.path))
            f.close
            f.unlink 
          end
            
          # Log the processing time
          metrics[:end_time] = Time.now
          METRICS_PROCESSOR.metric(metrics)
        end
      end
    end
  end
end

# Run this as "main" if the library is invoked directly
if ($0 == __FILE__) 
  Process.daemon(true) unless($DEBUG)
  agent = AnalysisAgent.new
  agent.poll!
end

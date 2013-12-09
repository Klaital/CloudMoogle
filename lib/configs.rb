require 'yaml'
require 'logger'
require 'date'
require 'time'
require 'rubygems'
require 'aws-sdk'

CREDS = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'config', 'credentials.yaml'))
CONFIGS = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)) , '..', 'config', 'configuration.yaml'))

# Adding a nice compacting method to the Hash based on value
class Hash
    def compact!
        delete_if {|k,v| v.nil?}
    end
end

# Adding customized logging methods. 
# These check out the app config for the log level and optionally whether to echo onto stdout as well.
class Logger
  def d(msg=nil)
    s = if (block_given? && CONFIGS[:logs][:level] <= 0)
      yield
    else
      msg
    end

    puts "DEBUG #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] <= 0)
    debug s
  end
  def i(msg=nil)
    s = if (block_given? && CONFIGS[:logs][:level] <= 1)
      yield
    else
      msg
    end

    puts " INFO #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] <= 1)
    info s
  end
  def e(msg=nil)
    s = if (block_given? && CONFIGS[:logs][:level] <= 2)
      yield
    else
      msg
    end

    puts "ERROR #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] <= 2)
    error s
  end
  def w(msg=nil)
    s = if (block_given? && CONFIGS[:logs][:level] <= 3)
      yield
    else
      msg
    end

    puts " WARN #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] <= 3)
    warn s
  end
  def f(msg=nil)
    s = if (block_given? && CONFIGS[:logs][:level] <= 4)
      yield
    else
      msg
    end

    puts "FATAL #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] <= 4)
    fatal s
  end
  def u(msg)
    s = if (block_given? && CONFIGS[:logs][:stdout])
      yield
    else
      msg
    end

    puts "  ANY #{s}" if (CONFIGS[:logs][:stdout])
    unknown s
  end
  
  def metric( data = {} )
    data = data.collect do |k,v| 
      val = (v.respond_to?(:iso8601)) ? v.iso8601 : v.to_s
      "#{k}=#{val}\n"
    end
    debug "#{SPACER}\n#{data.join('')}"
  end
end

SPACER = '=========================================='
TODAY = Time.now

log_path = File.join( File.expand_path(File.dirname(__FILE__)), '..', 'logs', CONFIGS[:logs][:filename])
Dir.mkdir(File.dirname(log_path)) unless(Dir.exists?(File.dirname(log_path)))
LOGGER = Logger.new ( log_path )
LOGGER.level = CONFIGS[:logs][:level].to_i
LOGGER.datetime_format = '%Y-%m-%dT%H:%M:%S'
METRICS_PROCESSOR = Logger.new('/var/log/cloudmoogle/metrics_processor.log', 'daily')
METRICS_PROCESSOR.formatter = proc{ |level, datetime, progname, msg| msg}
METRICS_PROCESSOR.level = 0

aws_config = {
  :access_key_id => CREDS[:aws][:access_key], 
  :secret_access_key => CREDS[:aws][:secret], 
  :region=>'us-west-2'
}
AWS.config(aws_config)

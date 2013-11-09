require 'yaml'
require 'logger'
require 'date'
# require 'mysql'
require 'rubygems'
require 'aws-sdk'

CREDS = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/credentials.yaml'))
CONFIGS = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/configuration.yaml'))

# Adding customized logging methods. 
# These check out the app config for the log level and optionally whether to echo onto stdout as well.
class Logger
	def d(msg=nil)
		s = if (block_given? && CONFIGS[:logs][:level] >= 0)
			yield
		else
			msg
		end

		puts "DEBUG #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 0)
		debug s
	end
	def i(msg=nil)
		s = if (block_given? && CONFIGS[:logs][:level] >= 1)
			yield
		else
			msg
		end

		puts " INFO #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 1)
		info s
	end
	def e(msg=nil)
		s = if (block_given? && CONFIGS[:logs][:level] >= 2)
			yield
		else
			msg
		end

		puts "ERROR #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 2)
		error s
	end
	def w(msg=nil)
		s = if (block_given? && CONFIGS[:logs][:level] >= 3)
			yield
		else
			msg
		end

		puts " WARN #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 3)
		warn s
	end
	def f(msg=nil)
		s = if (block_given? && CONFIGS[:logs][:level] >= 4)
			yield
		else
			msg
		end

		puts "FATAL #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 4)
		fatal s
	end
	def u(msg)
		s = if (block_given? && CONFIGS[:logs][:stdout])
			yield
		else
			msg
		end

		puts "  ANY #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 3)
		unknown s
	end
end

LOGGER = Logger.new ( File.join( File.expand_path(File.dirname(__FILE__)), '..', 'logs', CONFIGS[:logs][:filename]), 'daily')
LOGGER.level = CONFIGS[:logs][:level].to_i
LOGGER.datetime_format = '%Y-%m-%dT%H:%M:%S'

AWS.config({:access_key_id => CREDS[:aws][:access_key], :secret_access_key => CREDS[:aws][:secret]})

# PARTY_CONFIG_MYSQL = Mysql.new(CREDS[:db][:party_config][:host], 
#                 CREDS[:db][:party_config][:username], 
#                 CREDS[:db][:party_config][:password], 
#                 CREDS[:db][:party_config][:schema])


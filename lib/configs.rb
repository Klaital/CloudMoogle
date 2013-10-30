require 'yaml'
require 'logger'
require 'date'
require 'mysql'
require 'rubygems'
require 'aws-sdk'

CREDS = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/credentials.yml'))
CONFIGS = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/configuration.yml'))

# Adding customized logging methods.
# TODO: add proper block support. These methods are a performance penalty, even when the logging level is raised.
class Logger
	def d(msg=nil)
		s = if (block_given? && CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 0)
			yield
		else
			msg
		end

		puts "DEBUG #{s}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 0)
		debug msg
	end
	def i(msg)
		puts " INFO #{msg}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 1)
		info msg
	end
	def e(msg)
		puts "ERROR #{msg}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 2)
		error msg
	end
	def w(msg)
		puts " WARN #{msg}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 3)
		warn msg
	end
	def f(msg)
		puts "FATAL #{msg}" if (CONFIGS[:logs][:stdout] && CONFIGS[:logs][:level] >= 4)
		fatal msg
	end
	def u(msg)
		puts "  ANY #{msg}"
		unknown msg
	end
end

LOGGER = Logger.new ( File.expand_path(File.dirname(__FILE__) + '/../logs/' + CONFIGS[:logs][:filename], 'daily') )
LOGGER.level = CONFIGS[:logs][:level].to_i
LOGGER.datetime_format = '%Y-%m-%dT%H:%M:%S'

AWS.config({:access_key_id => CREDS[:aws][:access_key], :secret_access_key => CREDS[:aws][:secret]})

PARTY_CONFIG_MYSQL = Mysql.new(CREDS[:db][:party_config][:host], 
								CREDS[:db][:party_config][:username], 
								CREDS[:db][:party_config][:password], 
								CREDS[:db][:party_config][:schema])


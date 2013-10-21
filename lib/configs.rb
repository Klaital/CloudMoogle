require 'yaml'
require 'logger'
require 'date'
require 'mysql'
require 'rubygems'
require 'aws-sdk'

CREDS = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/credentials.yml'))
CONFIGS = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/configuration.yml'))

LOGGER = Logger.new ( File.expand_path(File.dirname(__FILE__) + '/../logs/' + CONFIGS[:logs][:filename], 'daily') )
LOGGER.level = CONFIGS[:logs][:level].to_i
LOGGER.datetime_format = '%Y-%m-%dT%H:%M:%S'

aws_config = {
  :access_key_id => CREDS[:aws][:access],
  :secret_access_key => CREDS[:aws][:secret]
}
AWS.config(aws_config)

PARTY_CONFIG_MYSQL = Mysql.new(CREDS[:db][:party_config][:host], 
								CREDS[:db][:party_config][:username], 
								CREDS[:db][:party_config][:password], 
								CREDS[:db][:party_config][:schema])


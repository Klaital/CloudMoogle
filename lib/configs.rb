require 'yaml'
require 'logger'
require 'date'

CREDS = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/credentials.yml'))
CONFIGS = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/configuration.yml'))

LOGGER = Logger.new ( File.expand_path(File.dirname(__FILE__) + '/../logs/' + CONFIGS[:logs][:filename], 'daily')
LOGGER.level = CONFIGS[:logs][:level].to_i
LOGGER.datetime_format = '%Y-%m-%dT%H:%M:%S'


require 'test/unit'

require '../lib/Analyzer'

class TestAnalyzer < Test::Unit::TestCase
  def test_data_upload
    data = "<analysis><data>foo</data></analysis>"
    filename = "test-data.xml"

    a = Analyzer.new
    a.upload_analysis(filename, data)

    # TODO: verify that the data was uploaded to the correct bucket, with the correct name, etc
  end
end


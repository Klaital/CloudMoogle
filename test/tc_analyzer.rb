require 'test/unit'
require '../lib/configs'
require '../lib/Analyzer'

class TestAnalyzer < Test::Unit::TestCase
  def test_data_upload
    data = "<analysis><data>foo</data></analysis>"
    filename = "test-data.xml"

    a = Analyzer.new
    a.upload_analysis(filename, data)

    bucket = CONFIGS[:aws][:s3][:analysis_bucket]
    s3 = AWS::S3.new
    b = s3.buckets[bucket]
    check_data = b.objects[filename].read
    assert_equal(data,check_data)

    # Cleanup
    b.objects[filename].delete
  end
end

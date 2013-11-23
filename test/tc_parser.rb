require 'test/unit'
require_relative '../lib/Parser'

class TestParser < Test::Unit::TestCase
  def setup
    @p = Parser.new
  end
  def test_parse_simple
    s, a = Parser.parse_line("[14:59:01]Klaital hits the Colibri for 4 points of damage.", nil, 's')
    assert_not_nil(s)
    assert_equal("", s)
  end
end


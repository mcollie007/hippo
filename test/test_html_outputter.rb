require File.expand_path('test_helper', File.dirname(__FILE__))

class TestHTMLOutputter < MiniTest::Unit::TestCase
  def setup
    @parser = Hippo::Parser.new
    @sample_835 = @parser.parse_file('samples/005010X221A1_business_scenario_1.edi').first
    @sample_837 = @parser.parse_file('samples/005010X231A1_01.edi').first
  end

  def test_segment_to_html_returns_segment_to_s
    assert_equal @sample_835.BPR.to_s, @sample_835.BPR.to_html
  end

  def test_transaction_to_html_returns_string
    File.open('/Users/rjackson/Desktop/sample835.html', 'w') {|f| f.write(@sample_835.to_html) }
    File.open('/Users/rjackson/Desktop/sample837.html', 'w') {|f| f.write(@sample_837.to_html) }
    assert_kind_of String, @sample_835.to_html
  end
end
require File.join(File.dirname(__FILE__), 'test_helper')

class TestParser < MiniTest::Unit::TestCase
  def test_populate_segments_returns_array_of_segments
    parser = Hippo::Parser.new
    parser.read_file('samples/005010X221A1_business_scenario_1.edi')
    parser.populate_segments

    assert_instance_of Array, parser.segments

    parser.segments.each do |segment|
      assert_kind_of Hippo::Segments::Base, segment
    end
  end
end

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

  def test_parse_returns_array_of_transaction_sets
    parser = Hippo::Parser.new
    transaction_sets = parser.parse('samples/005010X221A1_business_scenario_1.edi')

    assert_instance_of Array, transaction_sets

    transaction_sets.each do |ts|
      assert_kind_of Hippo::TransactionSets::Base, ts
    end
  end
end

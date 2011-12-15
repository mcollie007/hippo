require File.expand_path('test_helper', File.dirname(__FILE__))

class TestParser < MiniTest::Unit::TestCase
  def setup
    @parser = Hippo::Parser.new
  end

  def test_parse_returns_array_of_transaction_sets
    transaction_sets = @parser.parse('samples/005010X221A1_business_scenario_1.edi')

    assert_instance_of Array, transaction_sets

    transaction_sets.each do |ts|
      assert_kind_of Hippo::TransactionSets::Base, ts
    end
  end

  def test_raises_error_on_extra_segments
    ts = Hippo::TransactionSets::Test::Base.new
    ts.ST
    ts.TSS.Field2 = 'Bar'
    ts.TSS.Field3 = 'Baz'
    ts.TCS.Field1 = 'Blah'
    ts.TCS.CompositeCommonName_02 = 'CNBlah'
    ts.TSS_02.Field2 = 'Boo'

    # test nested block syntax on non-looping component
    ts.L0001.TSS.Field2 = 'SubBar'

    # test nested block syntax on non-looping component
    ts.L0002 do |l0002|
      l0002.TCS.Field2 = 'SubBarBlah'
      l0002.TSS.Field2 = 'SubBarRepeater'
    end

    #'TSS*Blah*Bar*Baz~TCS*Blah*:::CNBlah*Preset Field 7~TSS*Last Segment*Boo~TSS*Foo*SubBar~TCS*:SubBarBlah**Foo2~TSS*Last Segment*SubBarRepeater~', ts.to_s

    @parser.raw_data = ts.to_s
    ts_result = @parser.populate_transaction_sets.first

    assert_equal ts.values.inspect, ts_result.values.inspect
  end

  def test_reads_separators_from_isa
    @parser.parse('samples/005010X231A1_01.edi')

    assert_equal @parser.field_separator,       '*'
    assert_equal @parser.repetition_separator,  '^'
    assert_equal @parser.composite_separator,   ':'
    assert_equal @parser.segment_separator,     '~'

    @parser = Hippo::Parser.new
    transaction_set = @parser.parse('samples/005010X231A1_02.edi')

    assert_equal @parser.field_separator,       '!'
    assert_equal @parser.repetition_separator,  '@'
    assert_equal @parser.composite_separator,   '~'
    assert_equal @parser.segment_separator,     '^'

    assert_equal transaction_set.first.ST.ST01, '999'
  end
end

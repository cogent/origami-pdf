require 'test/unit'

  class TC_Streams < Test::Unit::TestCase
    def setup
      @target = PDF.new

      @data = "0123456789" * 1024
    end

    # def teardown
    # end
    
    def test_png_predictors

      stm = Stream.new(@data, :Filter => :FlateDecode)
      stm.set_predictor(Filter::Predictor::PNG_SUB)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data

      stm.set_predictor(Filter::Predictor::PNG_UP)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data

      stm.set_predictor(Filter::Predictor::PNG_AVERAGE)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data

      stm.set_predictor(Filter::Predictor::PNG_PAETH)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data

   end
   
    def test_filter_flate

      stm = Stream.new(@data, :Filter => :FlateDecode)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data
    end

    def test_filter_asciihex

      stm = Stream.new(@data, :Filter => :ASCIIHexDecode)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data
    end

    def test_filter_ascii85

      stm = Stream.new(@data, :Filter => :ASCII85Decode)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data
    end

    def test_filter_rle

      stm = Stream.new(@data, :Filter => :RunLengthDecode)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data
    end

    def test_filter_lzw

      stm = Stream.new(@data, :Filter => :LZWDecode)
      raw = stm.rawdata
      stm.data = nil
      stm.rawdata = raw

      assert_equal stm.data, @data
    end

    def test_stream

      stm = Stream.new(@data, :Filter => :ASCIIHexDecode )

      @target << stm

      stm.pre_build
      assert stm.Length == stm.rawdata.length

      @target.saveas("/dev/null")
    end

end

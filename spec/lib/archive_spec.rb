require 'spec_helper'

module DbdumpArchiver
  PLAYGROUND_DIR = File.join(File.dirname(__FILE__), '..', 'test_data/playground')
  TEST_DBNAME = 'mydb'
  LOGGER = Logger.new(File.join(File.dirname(__FILE__), '../..', 'log/test.log'), datetime_format: '%H:%M:%S')

  describe Archive do
    after(:each) do
      Dir.glob("#{PLAYGROUND_DIR}/*.sql").each do |file|
        File.unlink(file)
      end
    end

    before(:each) do
      @archive = Archive.new(LOGGER, PLAYGROUND_DIR, TEST_DBNAME)
    end

    it 'touch_dump_file touches a file in the playground dir' do
      time_str = '20180204_1111'
      touch_dump_file(:daily, time_str)
      assert_dump_file_exist(:daily, time_str)
    end

    it 'creates a weekly file from Sunday daily file' do
      touch_dump_file(:daily, '20180913_1111')
      touch_dump_file(:daily, '20180912_1111')
      touch_dump_file(:daily, '20180911_1111')
      touch_dump_file(:daily, '20180910_1111')
      touch_dump_file(:daily, '20180909_1111') #Sunday
      touch_dump_file(:daily, '20180908_1111')

      @archive.archive

      assert_dump_file_exist(:weekly, '20180909_1111')
      assert_dump_file_exist(:daily, '20180909_1111', false)
      assert_dump_file_exist(:daily, '20180913_1111')
    end

    it 'creates a monthly file from weekly in first week of month' do
      touch_dump_file(:weekly, '20180930_1111')
      touch_dump_file(:weekly, '20180923_1111')
      touch_dump_file(:weekly, '20180916_1111')
      touch_dump_file(:weekly, '20180909_1111') # Sunday
      touch_dump_file(:weekly, '20180902_1111') # First week

      @archive.archive

      assert_dump_file_exist(:monthly, '20180902_1111')
      assert_dump_file_exist(:weekly, '20180902_1111', false)
      assert_dump_file_exist(:weekly, '20180930_1111')
      assert_dump_file_exist(:weekly, '20180923_1111')
      assert_dump_file_exist(:weekly, '20180916_1111')
      assert_dump_file_exist(:weekly, '20180909_1111')
    end

    it 'creates a yearly file from monthly in first month of year' do
      touch_dump_file(:monthly, '20180530_1111')
      touch_dump_file(:monthly, '20180423_1111')
      touch_dump_file(:monthly, '20180316_1111')
      touch_dump_file(:monthly, '20180209_1111') # Sunday
      touch_dump_file(:monthly, '20180102_1111') # First week

      @archive.archive

      assert_dump_file_exist(:yearly,  '20180102_1111')
      assert_dump_file_exist(:monthly, '20180102_1111', false)
      assert_dump_file_exist(:monthly, '20180530_1111')
      assert_dump_file_exist(:monthly, '20180423_1111')
      assert_dump_file_exist(:monthly, '20180316_1111')
      assert_dump_file_exist(:monthly, '20180209_1111')
    end

    it 'deletes all daily files older than 10 days' do
      allow(Time).to receive(:now).and_return(Time.mktime(2018,9,21))

      touch_dump_file(:daily, '20180913_1111')
      touch_dump_file(:daily, '20180912_1111')
      touch_dump_file(:daily, '20180911_1111')
      touch_dump_file(:daily, '20180910_1111')
      touch_dump_file(:daily, '20180909_1111')
      touch_dump_file(:daily, '20180908_1111')

      @archive.archive

      assert_dump_file_exist(:daily, '20180911_1111')
      assert_dump_file_exist(:daily, '20180910_1111', false)
      assert_dump_file_exist(:daily, '20180909_1111', false)
      assert_dump_file_exist(:daily, '20180908_1111', false)
    end

    it 'deletes all weekly files older than 5 weeks' do
      allow(Time).to receive(:now).and_return(Time.mktime(2018,10,02))

      touch_dump_file(:weekly, '20180930_1111')
      touch_dump_file(:weekly, '20180923_1111')
      touch_dump_file(:weekly, '20180916_1111')
      touch_dump_file(:weekly, '20180909_1111')
      touch_dump_file(:weekly, '20180826_1111')
      touch_dump_file(:weekly, '20180819_1111')

      @archive.archive

      assert_dump_file_exist(:weekly, '20180826_1111', false)
      assert_dump_file_exist(:weekly, '20180819_1111', false)
      assert_dump_file_exist(:weekly, '20180930_1111')
      assert_dump_file_exist(:weekly, '20180923_1111')
      assert_dump_file_exist(:weekly, '20180916_1111')
      assert_dump_file_exist(:weekly, '20180909_1111')
    end

    def touch_dump_file(period, time_str)
      filename = "#{PLAYGROUND_DIR}/#{TEST_DBNAME}-#{period}-#{time_str}.sql"
      f = File.open(filename, "w")
      f.close
    end

    def assert_dump_file_exist(period, time_str, exist=true)
      filename = "#{PLAYGROUND_DIR}/#{TEST_DBNAME}-#{period}-#{time_str}.sql"
      expect(File.exist?(filename)).to be exist
    end
  end
end

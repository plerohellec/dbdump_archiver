require 'spec_helper'

module DbdumpArchiver
  describe DumpFile do
    it "determines the time of a dumpfile" do
      dumpfile = DumpFile.new("/dir/dbname-daily-20180102_1400.dump")
      expect(dumpfile.utc_time).to eq(Time.new(2018, 1, 2, 14, 0, 0, "+00:00"))
    end
  end
end

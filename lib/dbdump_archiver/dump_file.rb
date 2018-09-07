require 'date'

module DbdumpArchiver
  class DumpFile
    attr_reader :filename
    
    def initialize(filename)
      @filename = filename
    end

    def utc_time
      if @filename =~ /(\d{8}_\d{4})\.sql/
        time_str = $1
      else
        raise RuntimeError, "No time found in #{@filename}"
      end

      t = DateTime.strptime(time_str, '%Y%m%d_%H%M').to_time
      t.utc
    end
  end
end

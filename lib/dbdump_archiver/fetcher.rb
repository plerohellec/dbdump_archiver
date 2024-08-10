module DbdumpArchiver
  class Fetcher
    attr_reader :logger

    def initialize(logger, pg_dump, host, port, dbname, username, password, archive_dir)
      @logger = logger
      @pg_dump = pg_dump
      @host = host
      @port = port
      @dbname = dbname
      @username = username
      @password = password
      @archive_dir = archive_dir
    end

    def fetch
      if dump = exist_dump_file_for_today?
        logger.info "Skipping fetch since a dump already exist for today #{dump}"
        return
      end

      logger.info "Fetching #{@dbname} from #{@host}..."
      cmd = "#{@pg_dump} -U #{@username} -h #{@host} -p #{@port} -d #{@dbname} -Fc -f #{dump_filename}"
      result = system("PGPASSWORD='#{@password}' #{cmd}")
      if result
        logger.info "pg_dump_successful to #{dump_filename}"
      else
        logger.error "The pg_dump command failed: #{cmd}"
        File.unlink(dump_filename)
      end
    end

    private

    def dump_filename
      "#{@archive_dir}/#{@dbname}-daily-#{Time.now.utc.strftime("%Y%m%d_%H%M")}.dump"
    end

    def exist_dump_file_for_today?
      today = Time.now.utc
      existing_files = Dir.glob("#{@archive_dir}/#{@dbname}-*-#{today.strftime("%Y%m%d")}_*.dump")
      existing_files.first
    end
  end
end

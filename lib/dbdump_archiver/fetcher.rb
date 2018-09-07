module DbdumpArchiver
  class Fetcher
    attr_reader :logger

    def initialize(logger, pg_dump, host, dbname, username, password, archive_dir)
      @logger = logger
      @pg_dump = pg_dump
      @host = host
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

      cmd = "PGPASSWORD='#{@password}' #{@pg_dump} -U #{@username} -h #{@host} -d #{@dbname} > #{dump_filename}"
      result = system(cmd)
      if result
        logger.debug "pg_dump_successful to #{dump_filename}"
      else
        logger.error "The pg_dump command failed: #{cmd}"
      end
    end

    private

    def dump_filename
      "#{@archive_dir}/#{@dbname}-daily-#{Time.now.utc.strftime("%Y%m%d_%H%M")}.sql"
    end

    def exist_dump_file_for_today?
      today = Time.now.utc
      existing_files = Dir.glob("#{@archive_dir}/#{@dbname}-daily-#{today.strftime("%Y%m%d")}_*.sql")
      existing_files.first
    end
  end
end

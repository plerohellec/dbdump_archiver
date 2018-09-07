module DbdumpArchiver
  class Archive
    def initialize(logger, archive_dir, dbname)
      @logger = logger
      @archive_dir = archive_dir
      @dbname = dbname
    end

    def archive
      periods = [
        { small: :daily,   large: :weekly,  klass: WeeklyArchiver },
        { small: :weekly,  large: :monthly, klass: MonthlyArchiver },
        { small: :monthly, large: :yearly,  klass: YearlyArchiver }
      ]

      periods.each do |period|
        archiver = period[:klass].new(@logger,
                                      period[:small],
                                      period[:large],
                                      existing_dump_files(period[:small]),
                                      existing_dump_files(period[:large]))
        num_promoted = archiver.promote
        num_deleted = archiver.delete_old

        @logger.info "promoted #{num_promoted} #{period[:large]} files, deleted #{num_deleted} #{period[:small]} files"
      end
    end

    def existing_dump_files(period)
      filenames = case period
      when :daily
        Dir.glob("#{@archive_dir}/#{@dbname}-daily-*.sql")
      when :weekly
        Dir.glob("#{@archive_dir}/#{@dbname}-weekly-*.sql")
      when :monthly
        Dir.glob("#{@archive_dir}/#{@dbname}-monthly-*.sql")
      when :yearly
        Dir.glob("#{@archive_dir}/#{@dbname}-yearly-*.sql")
      end

      filenames.map do |filename|
        DumpFile.new(filename)
      end
    end
  end

  class BaseArchiver
    def initialize(logger, small_period_name, large_period_name, smaller_dump_files, larger_dump_files)
      @logger = logger
      @smaller_dump_files = smaller_dump_files
      @larger_dump_files = larger_dump_files
      @small_period_name = small_period_name
      @large_period_name = large_period_name
    end

    def promote
      num_promoted = 0
      smaller_candidates_to_larger.each do |candidate|
        filename = candidate.filename
        new_basename = File.basename(filename).gsub(/#{@small_period_name}/, @large_period_name.to_s)
        new_fullname = File.dirname(filename) + '/' + new_basename
        @logger.debug "renaming #{candidate.filename} into #{new_fullname}"
        File.rename(candidate.filename, new_fullname)
        @smaller_dump_files.delete(candidate)
        @larger_dump_files.append(DumpFile.new(new_fullname))
        num_promoted += 1
      end
      num_promoted
    end

    def delete_old
      num_deleted = 0
      now = Time.now.utc
      @smaller_dump_files.each do |dump_file|
        if (now - dump_file.utc_time) / 86400 > max_retention_days
          @logger.debug "deleting #{dump_file.filename}"
          File.unlink(dump_file.filename)
          num_deleted += 1
        end
      end
      num_deleted
    end

    def smaller_candidates_to_larger
      @smaller_dump_files.select do |dump_file|
        next unless meets_promotion_condition(dump_file)
        !exist_larger_for_day?(dump_file.utc_time)
      end
    end

    def max_retention_days
      raise NotImplementedError
    end

    def meets_promotion_condition(dumpfile)
      raise NotImplementedError
    end

    def exist_larger_for_day?(time)
      year = time.year
      day = time.yday
      @larger_dump_files.detect do |larger|
        larger.utc_time.year == year && larger.utc_time.yday == day
      end
    end
  end

  class WeeklyArchiver < BaseArchiver
    def meets_promotion_condition(dumpfile)
      dumpfile.utc_time.wday == 0
    end

    def max_retention_days
      10
    end
  end

  class MonthlyArchiver < BaseArchiver
    def meets_promotion_condition(dumpfile)
      (1..7).include?(dumpfile.utc_time.mday)
    end

    def max_retention_days
      35
    end
  end

  class YearlyArchiver < BaseArchiver
    def meets_promotion_condition(dumpfile)
      dumpfile.utc_time.month == 1
    end

    def max_retention_days
      400
    end
  end
end

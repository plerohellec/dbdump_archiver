require 'dbdump_archiver'

namespace :dbdump_archiver do
  CONFIG_FILENAME = ENV.fetch('DBARCHIVER_CONFIG', 'config/archiver.yml')
  LOGFILE = ENV.fetch('DBARCHIVER_LOGFILE', STDOUT)

  desc 'Fetch a database dump'
  task :fetch do
    dbname = ENV.fetch('DBARCHIVER_DBNAME')
    fetch_database(dbname)
  end

  desc 'Promote dump files to weekly/monthly/yearly and delete old ones'
  task :archive do
    dbname = ENV.fetch('DBARCHIVER_DBNAME')
    archive_database(dbname)
  end

  desc 'Fetch a database dump and promote archive'
  task :fetch_and_archive => [ :fetch, :archive ] do
  end

  desc 'Fetch all database dumps'
  task :fetch_all do
    config.databases.each do |dbname, dbcreds|
      fetch_database(dbname)
    end
  end

  desc 'Archive all databases'
  task :archive_all do
    config.databases.each do |dbname, dbcreds|
      archive_database(dbname)
    end
  end

  desc 'Fetch and archive all databases'
  task :fetch_and_archive_all => [ :fetch_all, :archive_all ] do
  end

  def fetch_database(dbname)
    db = config.databases[dbname]
    fetcher = DbdumpArchiver::Fetcher.new(logger,
        config.pg_dump_path,
        db['host'],
        db.fetch('port', 5432)
        dbname,
        db['username'],
        db['password'],
        db['archive_dir'])
    fetcher.fetch
  end

  def archive_database(dbname)
    db = config.databases[dbname]
    archive = DbdumpArchiver::Archive.new(logger, db['archive_dir'], dbname)
    archive.archive
  end

  def config
    @config ||= DbdumpArchiver::Config.new(CONFIG_FILENAME)
  end

  def logger
    @logger ||= Logger.new(LOGFILE, datetime_format: '%H:%M:%S')
  end
end

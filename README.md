# DbdumpArchiver

* Fetch Postgresql database dumps using pg_dump.
* Archive dumps by promoting daily dumping into weekly, weekly into monthly and and monthly into yearly.
* Remove old dump files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dbdump_archiver'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dbdump_archiver

## Requirements
Your Postgresql databases must have a user/role with CONNECT and SELECT privileges to the databases
you want backed up.

`pg_dump` must be available on the machine running the gem.
Path to the executable can be specified in the config file.

## Usage
Create a directory where to store the dump file, for example `./dumps`.

Create a configuration file `archiver.yml`.
Contents look like this:

```yaml
pg_dump_path: '/usr/lib/postgresql/10/bin/pg_dump'
databases:
  sample_db_name:
    host: 'db.example.com'
    username: 'backups'
    password: 'secret'
    archive_dir: './dumps'
```

After checking out the gem and running `bundle install`, run this command from the gem root directory to fetch and archive all existing dump files listed in the configuration file:

```sh
export DBARCHIVER_LOGFILE='./archiver.log'
export DBARCHIVER_CONFIG='./archiver.yml'
bundle exec rake dbdump_archiver:fetch_and_archive_all
```

Setup a cronjob that runs at least once a day and executes the rake task above. This rake task is idempotent
so it won't fetch more dumps than it needs.

This rake task is responsible for fetching, archiving and aging the dump files.

### Fetching the database dumps
At most 1 dump file will be fetched per database per day and it will be called `{dbname}-daily-yyyymmdd_hhmm.dump`.

### Archiving the database dumps
The daily dumps fetched on Sundays (GMT) will be renamed to **weekly**:
`{dbname}-weekly-yyyymmdd_hhmm.dump`.

The weekly dumps created during the first week of each month will be renamed to **monthly**:
`{dbname}-monthly-yyyymmdd_hhmm.dump`

The monthly dumps created during the first month of each year will bee renamed to **yearly**:
`{dbname}-yearly-yyyymmdd_hhmm.dump`

### Aging the database dumps
The rake task will retain the following numbers of dump files.
* 10 dailies
* 5 weeklies
* 13 monthlies
* yearlies: no limit

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/plerohellec/dbdump_archiver.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

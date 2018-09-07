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

## Usage
Your Postgres install must have a user with CONNECT and SELECT privileges to the databases
you want backed up.

Create a directory where to store the dump file, for example `./dumps`.

Create a configuration file `archiver.yml`.
Contents look like this:

```yaml
pg_dump_path: '/usr/lib/postgresql/10/bin/pg_dump'
databases:
  sample_db_name:
    host: 'www.example.com'
    username: 'backups'
    password: 'secret'
    archive_dir: './dumps'
```

Run this command to both fetch and archive all existing dump files listed in the configuration file:

```sh
export DBARCHIVER_LOGFILE='./archiver.log'
bundle exec rake dbdump_archiver:fetch_and_archive_all
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/plerohellec/dbdump_archiver.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

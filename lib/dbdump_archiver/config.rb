require 'yaml'

module DbdumpArchiver
  class Config
    def initialize(config_filename)
      @config_filename = config_filename
    end

    def config
      @config ||= YAML.load(File.read(@config_filename))
    end

    def pg_dump_path
      config['pg_dump_path']
    end

    def databases
      config['databases']
    end

    def database(dbname)
      config['databases'][dbname]
    end
  end
end

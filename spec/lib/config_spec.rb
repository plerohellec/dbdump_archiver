require 'spec_helper'

module DbdumpArchiver
  describe Config do
    before :each do
      @cfg = Config.new(File.join(File.dirname(__FILE__), '..', 'test_data/archiver.yml'))
    end

    it "returns the pg_dump_path" do
      expect(@cfg.pg_dump_path).to eq('/usr/lib/postgresql/10/bin/pg_dump')
    end

    it "return the full list of databases" do
      expect(@cfg.databases.keys).to eq([ 'db_one', 'db_two'])
    end

    it "returns attributes of a database" do
      expect(@cfg.database('db_one')['host']).to eq('www.example-one.com')
    end
  end
end

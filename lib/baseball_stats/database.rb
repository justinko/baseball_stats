require 'sequel'
require 'logger'

module BaseballStats
  class Database
    extend Forwardable

    def_delegators :@connection, :[], :<<

    def initialize(env = 'development')
      @connection = Sequel.sqlite(database: "data/#{env}", logger: Logger.new("log/#{env}.log"))
    end

    def create_tables
      @connection.create_table! :players do
        string :id
        integer :birth_year
        string :first_name
        string :last_name
        index :id
      end

      @connection.create_table! :statistics do
        string :player_id
        integer :year
        string :team
        integer :games
        integer :at_bats
        integer :runs
        integer :hits
        integer :doubles
        integer :triples
        integer :home_runs
        integer :runs_batted_in
        integer :stolen_bases
        integer :caught_stealing
        index :player_id
      end
    end

    def import_data
      import :players, 'data/Master-small.csv'
      import :statistics, 'data/Batting-07-12.csv'
    end

    private

    def import(table_name, file_name)
      @connection[table_name].import @connection[table_name].columns, CSVParser.parse(file_name)
    end
  end
end

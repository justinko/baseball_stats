require 'baseball_stats/csv_parser'
require 'baseball_stats/database'
require 'baseball_stats/runner'

module BaseballStats
  def self.db
    @database
  end

  def self.db=(database)
    @database = database
  end
end



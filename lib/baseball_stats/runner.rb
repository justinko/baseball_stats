require 'baseball_stats/stats/stat'
require 'baseball_stats/stats/most_improved_batting_average'
require 'baseball_stats/stats/most_improved_fantasy_players'
require 'baseball_stats/stats/slugging_percentage_for_team'
require 'baseball_stats/stats/triple_crown_winners'

module BaseballStats
  class Runner
    def initialize
      @out = STDOUT
    end

    def run
      BaseballStats.db = Database.new
      BaseballStats.db.create_tables
      BaseballStats.db.import_data

      output 'Most improved batting average from 2009 to 2010'
      output '-----------------------------------------------'
      output Stats::MostImprovedBattingAverage.new(from: 2009, to: 2010).data
      output
      output "Slugging percentage for the Oakland A's in 2007"
      output '-----------------------------------------------'
      output Stats::SluggingPercentageForTeam.new(year: 2007, team: 'OAK').data
      output
      output 'Most improved fantasy players from 2011 to 2012'
      output '-----------------------------------------------'
      output Stats::MostImprovedFantasyPlayers.new(from: 2011, to: 2012).data
      output
      output 'Triple Crown winners for 2011 and 2012'
      output '--------------------------------------'
      output Stats::TripleCrownWinners.new(years: [2011, 2012]).data
    end

    private

    def output(data = '')
      Array(data).each {|row| @out.puts Array(row).map {|value| String(value).ljust(20) }.join }
    end
  end
end

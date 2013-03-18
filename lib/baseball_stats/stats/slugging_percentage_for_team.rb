module BaseballStats
  module Stats
    class SluggingPercentageForTeam < Stat
      def data
        super {|stat, rows| rows << [stat.player_name, stat[:slugging_percentage]] }
      end

      private

      def sql; <<-SQL
SELECT
  s.player_id
  ,p.first_name || ' ' || p.last_name AS name
  ,IFNULL(ROUND(CAST(
    (s.hits - s.doubles - s.triples - s.home_runs) +
    (2 * s.doubles) +
    (3 * s.triples) +
    (4 * s.home_runs)
    AS REAL
  ) / s.at_bats, 4), 0.0) AS slugging_percentage
FROM statistics s
LEFT JOIN players p ON p.id = s.player_id
WHERE year = #{year}
AND team = '#{team}'
ORDER BY slugging_percentage DESC
SQL
      end
    end
  end
end

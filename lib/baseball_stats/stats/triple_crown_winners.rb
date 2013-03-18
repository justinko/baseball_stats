module BaseballStats
  module Stats
   class TripleCrownWinners < Stat
      def data
        super do |stat, rows|
          rows << [stat[:year]].tap do |row|
            if not stat[:winner].zero?
              row << stat.player_name
              row << "HR: #{stat[:home_runs]}"
              row << "RBI: #{stat[:runs_batted_in]}"
              row << "BA: #{stat[:batting_average]}"
            else
              row << '(No winner)'
            end
          end
        end
      end

      private

      def sql; <<-SQL
SELECT
  s.player_id
  ,s.year
  ,(p.first_name || ' ' || p.last_name) AS name
  ,MAX(home_runs) home_runs
  ,s_rbi.runs_batted_in
  ,CASE WHEN s_rbi.runs_batted_in IS NULL THEN 0 ELSE 1 END winner
  ,s_ba.batting_average
FROM statistics s
  LEFT OUTER JOIN (
    SELECT player_id, year, MAX(runs_batted_in) runs_batted_in
    FROM statistics
    where year IN (#{joined_years})
    GROUP BY year
  ) s_rbi ON s_rbi.player_id = s.player_id and s_rbi.year = s.year
  LEFT OUTER JOIN (
    SELECT player_id, year, ROUND(SUM(CAST(hits AS REAL)) / SUM(at_bats), 4) AS batting_average
    FROM statistics
    where year IN (#{joined_years})
    GROUP BY year, player_id
  ) s_ba ON s_ba.player_id = s.player_id and s_ba.year = s.year
LEFT OUTER JOIN players p ON p.id = s.player_id
WHERE s.year IN (#{joined_years})
GROUP BY s.year
SQL
      end

      def joined_years
        years.join(',')
      end
    end
  end
end

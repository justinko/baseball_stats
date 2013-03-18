module BaseballStats
  module Stats
    class MostImprovedBattingAverage < Stat
      default :minimum_at_bats, 200

      def data
        super do |stat, rows|
          rows << [
            stat.player_name,
            "#{from} AB: #{stat[:to_at_bats]}",
            "#{from} H: #{stat[:to_hits]}",
            "#{to} AB: #{stat[:from_at_bats]}",
            "#{to} H: #{stat[:from_hits]}",
            "#{from} BA: #{stat[:to_batting_average]}",
            "#{to} BA: #{stat[:from_batting_average]}",
            "BA DIFF: #{stat[:batting_average_difference]}"
          ]
        end
      end

      private

      def sql; <<-SQL
SELECT
  s.player_id
  ,(p.first_name || ' ' || p.last_name) AS name
  ,SUM(IFNULL(s_from.at_bats, 0)) from_at_bats
  ,SUM(IFNULL(s_from.hits, 0)) from_hits
  ,SUM(IFNULL(s_to.at_bats, 0)) to_at_bats
  ,SUM(IFNULL(s_to.hits, 0)) to_hits
  ,ROUND(SUM(IFNULL(s_from.batting_average, 0.0)), 4) from_batting_average
  ,ROUND(SUM(IFNULL(s_to.batting_average, 0.0)), 4) to_batting_average
  ,ROUND(
    SUM(IFNULL(s_to.batting_average, 0.0)) - SUM(IFNULL(s_from.batting_average, 0.0)), 4
  ) batting_average_difference
FROM statistics s
  LEFT OUTER JOIN (
    SELECT
      player_id
      ,year
      ,SUM(at_bats) as at_bats
      ,SUM(hits) as hits
      ,SUM(CAST(hits AS REAL)) / SUM(at_bats) as batting_average
    FROM statistics
    WHERE year = #{from}
    GROUP BY player_id, year
  ) s_from ON (s_from.player_id = s.player_id AND s_from.year = s.year)
  LEFT OUTER JOIN (
    SELECT
      player_id
      ,year
      ,SUM(at_bats) as at_bats
      ,SUM(hits) as hits
      ,SUM(CAST(hits AS REAL)) / SUM(at_bats) as batting_average
    FROM statistics
    WHERE year = #{to}
    GROUP BY player_id, year
  ) s_to ON s_to.player_id = s.player_id and s_to.year = s.year
  LEFT OUTER JOIN players p ON p.id = s.player_id
GROUP BY s.player_id
HAVING SUM(s_from.at_bats) >= #{minimum_at_bats}
  AND SUM(s_to.at_bats) >= #{minimum_at_bats}
ORDER BY batting_average_difference DESC
LIMIT 1
SQL
      end
    end
  end
end

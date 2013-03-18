module BaseballStats
  module Stats
    class MostImprovedFantasyPlayers < Stat
      default :minimum_at_bats, 500

      def data
        super do |stat, rows|
          rows << [
            stat.player_name,
            "#{from} FS: #{stat[:from_fantasy_score]}",
            "#{to} FS: #{stat[:to_fantasy_score]}",
            "FS DIFF: #{stat[:fantasy_score_difference]}"
          ]
        end
      end

      private

      def sql; <<-SQL
SELECT
  s.player_id
  ,(p.first_name || ' ' || p.last_name) AS name
  ,SUM(IFNULL(s_from.fantasy_score, 0)) from_fantasy_score
  ,SUM(IFNULL(s_to.fantasy_score, 0)) to_fantasy_score
  ,SUM(IFNULL(s_to.fantasy_score, 0)) - SUM(IFNULL(s_from.fantasy_score, 0)) fantasy_score_difference
FROM statistics s
  LEFT OUTER JOIN (
    SELECT
      player_id
      ,year
      ,SUM(at_bats) at_bats
      ,(
        (4 * SUM(home_runs)) +
        SUM(runs_batted_in) +
        SUM(stolen_bases) +
        SUM(caught_stealing)
      ) AS fantasy_score
    FROM statistics
    WHERE year = #{from}
    GROUP BY player_id, year
  ) s_from ON (s_from.player_id = s.player_id AND s_from.year = s.year)
  LEFT OUTER JOIN (
    SELECT
      player_id
      ,year
      ,SUM(at_bats) at_bats
      ,(
        (4 * SUM(home_runs)) +
        SUM(runs_batted_in) +
        SUM(stolen_bases) +
        SUM(caught_stealing)
      ) AS fantasy_score
    FROM statistics
    WHERE year = #{to}
    GROUP BY player_id, year
  ) s_to ON (s_to.player_id = s.player_id AND s_to.year = s.year)
  LEFT OUTER JOIN players p ON p.id = s.player_id
GROUP BY s.player_id
HAVING SUM(s_from.at_bats) >= #{minimum_at_bats} AND SUM(s_to.at_bats) >= #{minimum_at_bats}
ORDER BY fantasy_score_difference DESC
LIMIT 5
SQL
      end
    end
  end
end

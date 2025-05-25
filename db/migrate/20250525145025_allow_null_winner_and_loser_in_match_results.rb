class AllowNullWinnerAndLoserInMatchResults < ActiveRecord::Migration[8.0]
  def change
    change_column_null :match_results, :winner_id, true
    change_column_null :match_results, :loser_id, true
  end
end

module MatchesHelper
  def match_result_indicator_class(match, player)
    if match.match_result.draw
      "bg-amber-500 dark:bg-amber-300"
    elsif match.match_result.winner_id == player.id
      "bg-green-600 dark:bg-green-300"
    else
      "bg-red-600 dark:bg-red-300"
    end
  end

  def match_result_text_class(match, player)
    if match.match_result.draw
      "text-amber-600 dark:text-amber-300"
    elsif match.match_result.winner_id == player.id
      "text-green-600 dark:text-green-300"
    else
      "text-red-600 dark:text-red-300"
    end
  end

  def match_result_text(match, player)
    if match.match_result.draw
      "Draw"
    elsif match.match_result.winner_id == player.id
      "Won"
    else
      "Lost"
    end
  end

  def opponent_for_player(match, player)
    if match.white_player_id == player.id
      match.black_player
    else
      match.white_player
    end
  end
end

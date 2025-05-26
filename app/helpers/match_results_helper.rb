module MatchResultsHelper
  def match_result_player_name(match_result, colour)
    if match_result.draw
      colour == :white ? match_result.match.white_player.full_name : match_result.match.black_player.full_name
    else
      colour == :white ? (match_result.winner&.full_name || "N/A") : (match_result.loser&.full_name || "N/A")
    end
  end
end

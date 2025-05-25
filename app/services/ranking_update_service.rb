class RankingUpdateService
  TEMP_RANK_OFFSET = 1000
  class InvalidMatchResultError < StandardError; end

  def self.call(match_result)
    new(match_result).call
  end

  def initialize(match_result)
    raise InvalidMatchResultError, "Match result is required" unless match_result
    
    @match_result = match_result
    @match = match_result.match
    validate_match_result!
  end

  def call
    ActiveRecord::Base.transaction do
      if @match_result.draw?
        handle_draw_result
      else
        handle_win_loss_result
      end
    end
  end

  private

  def validate_match_result!
    raise InvalidMatchResultError, "Match result is required" unless @match_result
    raise InvalidMatchResultError, "Match is required" unless @match

    if @match_result.draw?
      raise InvalidMatchResultError, "Players required for draw" unless @match.white_player && @match.black_player
    else
      raise InvalidMatchResultError, "Winner and loser required" unless @match_result.winner_id && @match_result.loser_id
    end
  end

  def handle_draw_result
    player_one = @match.white_player
    player_two = @match.black_player

    higher_ranked_player, lower_ranked_player = [ player_one, player_two ].sort_by(&:ranking)
    process_draw(higher_ranked_player, lower_ranked_player)
  end

  def handle_win_loss_result
    winner = Player.find(@match_result.winner_id)
    loser = Player.find(@match_result.loser_id)

    if winner.ranking < loser.ranking
      process_higher_ranked_wins(winner, loser)
    else
      process_lower_ranked_wins(winner, loser)
    end
  end

  def process_higher_ranked_wins(winner, loser)
  end

  def process_draw(higher_ranked_player, lower_ranked_player)
    return if adjacent_rankings?(higher_ranked_player.ranking, lower_ranked_player.ranking)

    new_lower_player_rank = lower_ranked_player.ranking - 1
    swap_players(lower_ranked_player, new_lower_player_rank)
  end

  def process_lower_ranked_wins(winner, loser)
    original_winner_rank = winner.ranking
    original_loser_rank = loser.ranking

    winner_improvement = calculate_rank_improvement(original_winner_rank, original_loser_rank)
    new_winner_rank = original_winner_rank - winner_improvement
    new_loser_rank = original_loser_rank + 1

    execute_lower_ranked_win_changes(winner, loser, new_winner_rank, new_loser_rank, original_winner_rank, original_loser_rank)
  end

  def execute_lower_ranked_win_changes(winner, loser, new_winner_rank, new_loser_rank, original_winner_rank, original_loser_rank)
    temp_rank = get_temp_ranking

    winner.update!(ranking: temp_rank)

    displaced_by_loser = swap_players(loser, new_loser_rank, original_loser_rank)

    shift_players_down(new_winner_rank, original_winner_rank, [ winner, displaced_by_loser ].compact)

    winner.update!(ranking: new_winner_rank)
  end

  def calculate_rank_improvement(winner_rank, loser_rank)
    rank_difference = winner_rank - loser_rank
    improvement = (rank_difference.to_f / 2)

    rank_difference > 1 ? improvement.floor : improvement.ceil
  end

  def swap_players(moving_player, target_rank, original_rank = nil)
    original_rank ||= moving_player.ranking
    displaced_player = Player.find_by(ranking: target_rank)

    return nil unless displaced_player && displaced_player != moving_player

    temp_rank = get_temp_ranking
    displaced_player.update!(ranking: temp_rank)
    moving_player.update!(ranking: target_rank)
    displaced_player.update!(ranking: original_rank)

    displaced_player
  end

  def shift_players_down(start_rank, end_rank, excluded_players = [])
    excluded_ids = excluded_players.compact.map(&:id)

    players_to_shift = Player.where("ranking >= ? AND ranking < ?", start_rank, end_rank)
                            .where.not(id: excluded_ids)
                            .order(ranking: :desc)

    players_to_shift.each do |player|
      old_rank = player.ranking
      new_rank = old_rank + 1
      player.update!(ranking: new_rank)
    end
  end

  def adjacent_rankings?(rank1, rank2)
    (rank1 - rank2).abs == 1
  end

  def get_temp_ranking
    Player.maximum(:ranking).to_i + TEMP_RANK_OFFSET
  end
end

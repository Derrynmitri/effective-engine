json.extract! match_result, :id, :match_id, :winner_id, :loser_id, :draw, :created_at, :updated_at
json.url match_result_url(match_result, format: :json)

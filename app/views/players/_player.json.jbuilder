json.extract! player, :id, :name, :surname, :birthday, :ranking, :user_id, :created_at, :updated_at
json.url player_url(player, format: :json)

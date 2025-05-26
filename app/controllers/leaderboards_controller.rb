class LeaderboardsController < ApplicationController
  def index
    @players = Player.order(ranking: :asc).limit(10)
  end
end

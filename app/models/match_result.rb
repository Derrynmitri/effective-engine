class MatchResult < ApplicationRecord
  belongs_to :match
  belongs_to :winner, class_name: "Player", optional: true
  belongs_to :loser, class_name: "Player", optional: true

  validates :match, presence: true
  validate :winner_and_loser_cannot_be_same

  after_save :update_rankings

  private

  def winner_and_loser_cannot_be_same
    return if draw?
    if winner_id.present? && loser_id.present? && winner_id == loser_id
      errors.add(:base, "Winner and loser cannot be the same player")
    end
  end

  def update_rankings
    RankingUpdateService.call(self)
  end
end

class MatchResult < ApplicationRecord
  belongs_to :match
  belongs_to :winner, class_name: "Player"
  belongs_to :loser, class_name: "Player"

  validates :match, presence: true
  validates :winner, presence: true
  validates :loser, presence: true
end

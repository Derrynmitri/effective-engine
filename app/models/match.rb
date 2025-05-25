class Match < ApplicationRecord
  belongs_to :white_player, class_name: "Player"
  belongs_to :black_player, class_name: "Player"

  has_one :match_result, dependent: :destroy

  validates :status, presence: true

  enum :status, { pending: 0, in_progress: 1, completed: 2, cancelled: 3 }, default: :pending
end

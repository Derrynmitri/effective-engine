class Player < ApplicationRecord
  belongs_to :user

  has_many :matches_as_white,
           class_name: "Match",
           foreign_key: "white_player_id",
           dependent: :restrict_with_error

  has_many :matches_as_black,
           class_name: "Match",
           foreign_key: "black_player_id",
           dependent: :restrict_with_error

  has_many :match_results_as_winner, class_name: "MatchResult", foreign_key: "winner_id", dependent: :restrict_with_error
  has_many :match_results_as_loser, class_name: "MatchResult", foreign_key: "loser_id", dependent: :restrict_with_error

  validates :name, presence: true
  validates :surname, presence: true
  validates :birthday, presence: true
  validate :birthday_must_be_in_the_past
  validates :ranking, presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 1 },
                      uniqueness: true

  attr_accessor :user_email, :user_password

  def email
    user&.email
  end

  def matches
    Match.where("white_player_id = :id OR black_player_id = :id", id: self.id)
  end

  def number_of_club_games_played(game_status: "completed")
    matches.where(status: game_status).count
  end

  private

  def birthday_must_be_in_the_past
    return if birthday.blank?
    date = birthday.is_a?(String) ? (Date.parse(birthday) rescue nil) : birthday
    if date.nil?
      errors.add(:birthday, "is not a valid date")
    elsif date >= Date.today
      errors.add(:birthday, "must be a valid date in the past")
    end
  end
end

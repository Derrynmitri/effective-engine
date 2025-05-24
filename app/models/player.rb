class Player < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :surname, presence: true
  validates :birthday, presence: true
  validate :birthday_must_be_in_the_past
  validates :ranking, presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 1 },
                      uniqueness: true

  def email
    user&.email
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

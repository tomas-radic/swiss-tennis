class Player < ApplicationRecord
  belongs_to :category
  has_many :match_assignments, dependent: :restrict_with_error
  has_many :matches, through: :match_assignments
  has_many :player1_matches, class_name: 'Match', foreign_key: :player1_id
  has_many :player2_matches, class_name: 'Match', foreign_key: :player2_id
  has_many :won_matches, class_name: 'Match', foreign_key: :winner_id
  has_many :rankings, dependent: :restrict_with_error
  has_many :rounds, through: :rankings
  has_many :enrollments, dependent: :restrict_with_error
  has_many :seasons, through: :enrollments

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :first_name,
            :last_name,
            presence: true

  scope :default, -> { where(dummy: false, active: true) }
end

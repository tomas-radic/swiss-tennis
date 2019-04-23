class Season < ApplicationRecord
  has_many :enrollments, dependent: :restrict_with_error
  has_many :players, through: :enrollments
  has_many :rounds, dependent: :restrict_with_error

  validates :name, presence: true

  scope :default, -> { order(created_at: :desc) } # (default_scope is not preferred)
end

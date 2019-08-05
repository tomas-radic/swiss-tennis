class Season < ApplicationRecord
  has_many :enrollments, dependent: :restrict_with_error
  has_many :players, through: :enrollments
  has_many :rounds, dependent: :restrict_with_error
  has_many :articles, dependent: :restrict_with_error

  validates :name, presence: true

  scope :default, -> { order(name: :desc) } # (default_scope is not preferred)
end

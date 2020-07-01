class Season < ApplicationRecord
  has_many :enrollments, dependent: :restrict_with_error
  has_many :players, through: :enrollments
  has_many :rounds, dependent: :restrict_with_error
  has_many :matches, through: :rounds
  has_many :rankings, through: :rounds
  has_many :articles, dependent: :restrict_with_error

  validates :name, :position, presence: true

  scope :default, -> { order(position: :desc) } # (default_scope is not preferred)

  acts_as_list
end

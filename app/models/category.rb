class Category < ApplicationRecord
  has_many :players, dependent: :restrict_with_error

  validates :name, presence: true

  scope :default, -> { order(created_at: :desc) } # (default_scope is not preferred)
end

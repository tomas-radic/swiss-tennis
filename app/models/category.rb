class Category < ApplicationRecord
  has_many :players, dependent: :restrict_with_error

  validates :name, :nr_finalists, presence: true

  scope :sorted, -> { order(position: :asc) }

  acts_as_list
end

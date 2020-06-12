class Place < ApplicationRecord

  has_many :matches, dependent: :nullify

  validates :name, presence: true

  scope :sorted, -> { order(position: :asc) }

  acts_as_list
end

class Round < ApplicationRecord
  belongs_to :season
  has_many :matches, dependent: :restrict_with_error

  acts_as_list scope: :season
end

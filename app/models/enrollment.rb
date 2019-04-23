class Enrollment < ApplicationRecord
  belongs_to :season
  belongs_to :player

  validates :player, uniqueness: { scope: :season }
end

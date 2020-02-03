class Enrollment < ApplicationRecord
  belongs_to :season
  belongs_to :player

  validates :player, uniqueness: { scope: :season }

  scope :active, -> { where(canceled_at: nil) }

  time_for_a_boolean :canceled
end

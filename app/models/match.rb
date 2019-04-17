class Match < ApplicationRecord
  belongs_to :player1, class_name: 'Player', foreign_key: :player1_id
  belongs_to :player2, class_name: 'Player', foreign_key: :player2_id
  belongs_to :winner, class_name: 'Player', foreign_key: :winner_id, optional: true
  belongs_to :round

  validates :type, presence: true

  scope :manual, -> { where(type: 'MatchManual') }
  scope :toss, -> { where(type: 'MatchToss') }
end

class Match < ApplicationRecord
  belongs_to :player1, class_name: 'Player', foreign_key: :player1_id
  belongs_to :player2, class_name: 'Player', foreign_key: :player2_id
  belongs_to :winner, class_name: 'Player', foreign_key: :winner_id, optional: true
  belongs_to :round

  validates :type, presence: true

  scope :manual, -> { where(type: 'MatchManual') }
  scope :toss, -> { where(type: 'MatchToss') }

  # 3.times do |i|
  #   set_number = i + 1
  #   define_method "set#{set_number}".to_sym do
  #     player1_score = instance_variable_get("attributes[:set#{set_number}_player1_score]".to_sym)
  #     player2_score = instance_variable_get("attributes[:set#{set_number}_player2_score]".to_sym)
  #     return '' if player1_score.nil? || player2_score.nil?
  #     "#{player1_score}:#{player2_score}"
  #   end
  # end
end

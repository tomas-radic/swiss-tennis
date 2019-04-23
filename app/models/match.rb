class Match < ApplicationRecord
  belongs_to :player1, class_name: 'Player', foreign_key: :player1_id
  belongs_to :player2, class_name: 'Player', foreign_key: :player2_id
  belongs_to :winner, class_name: 'Player', foreign_key: :winner_id, optional: true
  belongs_to :round

  validates :type, presence: true
  validate :players_are_different
  validate :winner_is_player
  validate :finished_when_published
  validates :set1_player1_score,
            :set1_player2_score,
            :winner,
            presence: true, if: :finished?

  scope :default, -> { order(:finished, :play_date, :play_hour, :play_minute) }
  scope :manual, -> { where(type: 'MatchManual') }
  scope :toss, -> { where(type: 'MatchToss') }
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :finished, -> { published.where.not(finished_at: nil) }
  scope :pending, -> { published.where(finished_at: nil) }

  time_for_a_boolean :finished

  # 3.times do |i|
  #   set_number = i + 1
  #   define_method "set#{set_number}".to_sym do
  #     player1_score = instance_variable_get("attributes[:set#{set_number}_player1_score]".to_sym)
  #     player2_score = instance_variable_get("attributes[:set#{set_number}_player2_score]".to_sym)
  #     return '' if player1_score.nil? || player2_score.nil?
  #     "#{player1_score}:#{player2_score}"
  #   end
  # end

  private

  def players_are_different
    errors.add(:player2, 'Hráč nemôže hrať sám so sebou') if player1 == player2
  end

  def winner_is_player
    return unless winner.present?

    if winner != player1 && winner != player2
      errors.add(:winner, 'Víťaz zápasu musí byť jeden z priradených hráčov')
    end
  end

  def finished_when_published
    if finished && !published
      errors.add(:published, 'Zápas musí byť verejný, ak je už skončený')
    end
  end
end

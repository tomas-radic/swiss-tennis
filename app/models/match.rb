class Match < ApplicationRecord
  has_many :match_assignments, dependent: :destroy
  has_many :players, through: :match_assignments
  belongs_to :player1, class_name: 'Player', foreign_key: :player1_id
  belongs_to :player2, class_name: 'Player', foreign_key: :player2_id
  belongs_to :winner, class_name: 'Player', foreign_key: :winner_id, optional: true
  belongs_to :looser, class_name: 'Player', foreign_key: :looser_id, optional: true
  belongs_to :retired_player, class_name: 'Player', foreign_key: :retired_player_id, optional: true
  belongs_to :round

  # validates :players, length: { is: 2 }
  validate :has_two_players
  validate :players_are_different
  validate :winner_is_player
  validate :looser_is_player
  validate :finished_when_published
  validate :players_available
  validates :winner,
            :looser,
            presence: true, if: :finished?

  scope :default, -> { order('matches.finished_at desc nulls last, matches.play_date asc nulls last, matches.updated_at desc, matches.note nulls last') }
  scope :manual, -> { where(from_toss: false) }
  scope :toss, -> { where(from_toss: true) }
  scope :published, -> { default.where(published: true) }
  scope :draft, -> { default.where(published: false) }
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

  def has_two_players
    errors.add(:players, 'Zápas musí mať presne dvoch hráčov') if players.length != 2
  end

  def players_are_different
    errors.add(:player2, 'Hráč nemôže hrať sám so sebou') if player1 == player2
  end

  def winner_is_player
    return unless winner.present?

    if winner != player1 && winner != player2
      errors.add(:winner, 'Víťaz zápasu musí byť jeden z priradených hráčov')
    end
  end

  def looser_is_player
    return unless looser.present?

    if looser != player1 && looser != player2
      errors.add(:looser, 'Porazený musí byť jeden z priradených hráčov')
    end
  end

  def finished_when_published
    if finished && !published
      errors.add(:published, 'Zápas musí byť verejný, ak je už skončený')
    end
  end

  def players_available
    conflicting_matches = Match.joins(:round, :players)
        .where('matches.id != ?', id)
        .where('rounds.id = ?', round_id)
        .where('players.id = ? or players.id = ?', player1_id, player2_id)

    errors.add(
      :players,
      'Niektorý z hráčov už je v tomto kole priradený do iného zápasu'
    ) if conflicting_matches.any?
  end
end

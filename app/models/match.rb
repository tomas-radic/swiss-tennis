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
  validates :set1_player1_score, :set1_player2_score,
            :set2_player1_score, :set2_player2_score,
            :set3_player1_score, :set3_player2_score,
            numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: 7
            },
            allow_nil: true
  validate :has_two_players
  validate :players_are_different
  validate :winner_is_player
  validate :looser_is_player
  validate :published_when_finished
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

  def been_played?
    set1_player1_score.to_i > 0 || set1_player2_score.to_i > 0
  end

  private

  def has_two_players
    errors.add(:players, 'Zápas musí mať presne dvoch hráčov') if player1_id.nil? || player2_id.nil?
  end

  def players_are_different
    errors.add(:player2, 'Hráč nemôže hrať sám so sebou') if player1_id == player2_id
  end

  def winner_is_player
    return unless winner_id.present?

    if winner_id != player1_id && winner_id != player2_id
      errors.add(:winner, 'Víťaz zápasu musí byť jeden z priradených hráčov')
    end
  end

  def looser_is_player
    return unless looser_id.present?

    if looser_id != player1_id && looser_id != player2_id
      errors.add(:looser, 'Porazený musí byť jeden z priradených hráčov')
    end
  end

  def published_when_finished
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

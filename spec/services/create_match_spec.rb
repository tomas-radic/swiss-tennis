require 'rails_helper'

describe CreateMatch do
  subject(:create_match) { described_class.call(attributes).result }

  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }
  let!(:round) { create(:round) }

  context 'With valid attributes' do
    let(:attributes) do
      {
        player1_id: player1.id,
        player2_id: player2.id,
        from_toss: false,
        round_id: round.id,
        published: true,
        play_date: Date.tomorrow.to_s,
        note: 'A note here',
        finished_at: Time.now.to_s,
        set1_player1_score: 4,
        set1_player2_score: 4,
        set2_player1_score: 4,
        set2_player2_score: 4,
        set3_player1_score: 4,
        set3_player2_score: 4
      }
    end

    it 'Returns persisted match' do
      match = create_match

      expect(match.persisted?).to be true
      expect(match.player1).to eq player1
      expect(match.player2).to eq player2
      expect(match.players.count).to eq 2
      expect(match.players.ids).to include(player1.id, player2.id)
      expect(match.published?).to be true
      expect(match.play_date).to eq Date.tomorrow
      expect(match.note).not_to be_nil
      expect(match.finished_at).to be_nil
      expect(MatchDecorator.new(match).score).to be_empty
    end
  end

  context 'With invalid attributes' do
    let(:attributes) do
      {
        player1_id: player1.id,
        player2_id: player2.id,
        from_toss: false
      }
    end

    it 'Returns unpersisted match' do
      match = create_match

      expect(match.persisted?).to be false
    end
  end
end

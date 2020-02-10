require 'rails_helper'

describe CreateMatch do
  subject(:create_match) { described_class.call(attributes).result }

  let!(:round) { create(:round) }

  context 'With players enrolled and having rankings' do
    let!(:player1) { create(:player, seasons: [round.season], rounds: [round]) }
    let!(:player2) { create(:player, seasons: [round.season], rounds: [round]) }

    context 'With valid attributes' do
      let(:attributes) do
        {
          player1_id: player1.id,
          player2_id: player2.id,
          round_id: round.id,
          published: true,
          play_date: Date.tomorrow.to_s,
          note: 'A note here'
        }
      end

      it 'Returns persisted match with correct attributes' do
        match = create_match

        expect(match.persisted?).to be true
        expect(match.player1).to eq player1
        expect(match.player2).to eq player2
        expect(match.players.count).to eq 2
        expect(match.players.ids).to include(player1.id, player2.id)
        expect(match.published?).to be true
        expect(match.play_date).to eq Date.tomorrow
        expect(match.note).to eq('A note here')
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

      it 'Does not create new match' do
        expect { create_match }.not_to change { Match.count }
      end
    end
  end

  context 'With player not enrolled to the match season' do
    let!(:player1) { create(:player, seasons: [], rounds: [round]) }
    let!(:player2) { create(:player, seasons: [round.season], rounds: [round]) }
    let(:attributes) do
      {
          player1_id: player1.id,
          player2_id: player2.id,
          round_id: round.id,
          published: true,
          play_date: Date.tomorrow.to_s,
          note: 'A note here'
      }
    end

    it 'Raises error' do
      expect { create_match }.to raise_error(CreateMatch::PlayerInvalidError)
    end

    it 'Does not create new match' do
      expect(Match.count).to eq 0
    end
  end

  context 'With player having canceled enrollment to the match season' do
    let!(:player1) { create(:player, seasons: [round.season], rounds: [round]) }
    let!(:player2) { create(:player, seasons: [round.season], rounds: [round]) }
    let(:attributes) do
      {
          player1_id: player1.id,
          player2_id: player2.id,
          round_id: round.id,
          published: true,
          play_date: Date.tomorrow.to_s,
          note: 'A note here'
      }
    end

    before do
      player1.enrollments.find_by(season_id: round.season_id).update!(canceled: true)
    end

    it 'Raises error' do
      expect { create_match }.to raise_error(CreateMatch::PlayerInvalidError)
    end

    it 'Does not create new match' do
      expect(Match.count).to eq 0
    end
  end

  context 'With player not having ranking for the match round' do
    let!(:player1) { create(:player, seasons: [round.season], rounds: [round]) }
    let!(:player2) { create(:player, seasons: [round.season], rounds: []) }
    let(:attributes) do
      {
          player1_id: player1.id,
          player2_id: player2.id,
          round_id: round.id,
          published: true,
          play_date: Date.tomorrow.to_s,
          note: 'A note here'
      }
    end

    it 'Raises error' do
      expect { create_match }.to raise_error(CreateMatch::PlayerInvalidError)
    end

    it 'Does not create new match' do
      expect(Match.count).to eq 0
    end
  end

  context 'With dummy player' do
    let!(:player1) { create(:player, seasons: [round.season], rounds: [round]) }
    let!(:player2) { create(:player, :dummy, seasons: [round.season], rounds: [round]) }
    let(:attributes) do
      {
          player1_id: player1.id,
          player2_id: player2.id,
          round_id: round.id,
          published: true,
          play_date: Date.tomorrow.to_s,
          note: 'A note here'
      }
    end

    it 'Returns persisted match with correct attributes' do
      match = create_match

      expect(match.persisted?).to be true
      expect(match.player1).to eq player1
      expect(match.player2).to eq player2
      expect(match.players.count).to eq 2
      expect(match.players.ids).to include(player1.id, player2.id)
      expect(match.published?).to be true
      expect(match.play_date).to eq Date.tomorrow
      expect(match.note).to eq('A note here')
      expect(match.finished_at).to be_nil
      expect(MatchDecorator.new(match).score).to be_empty
    end
  end
end

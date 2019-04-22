require 'rails_helper'

describe UpdateMatch do
  subject(:update_match) { described_class.call(attributes).result }

  describe 'Creating new match' do
    # Let there be match in previous rounds for assigned players

    it 'Creates new match' do

    end

    context 'Match is not finished yet' do
      it 'Does not create ranking record' do

      end
    end

    context 'Match is finished' do
      it 'Creates new ranking record' do

      end
    end

    context 'Match player already assigned to another match in this round' do
      it 'Raises error' do

      end
    end
  end

  describe 'Updating existing unfinished match' do
    it 'Updates given match' do

    end

    context 'Keeping match unfinished' do
      it 'Does not create ranking record' do

      end
    end

    context 'Switching to finished' do
      it 'Creates new ranking record' do

      end
    end
  end

  describe 'Updating existing finished match' do
    it 'Updates given match' do

    end

    context 'Keeping match finished' do
      it 'Does not create ranking record' do

      end
    end

    context 'Switching to unfinished' do
      it 'Destroys related ranking record' do

      end
    end
  end
end

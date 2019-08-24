require 'rails_helper'

describe PinArticle do
  subject(:pin_article) { described_class.call(article) }

  let!(:article) do
    create(:article, :draft, updated_at: 2.days.ago)
  end

  it 'Marks article published' do
    pin_article

    expect(article.reload.published?).to be true
  end

  it 'Sets updated_at to now' do
    pin_article

    expect(article.reload.updated_at).to be > Date.today.beginning_of_day
  end

  context 'When article is marked interesting until today or later' do
    before do
      article.update!(last_date_interesting: Date.today)
    end

    it 'Keeps last_date_interesting as is' do
      pin_article

      expect(article.reload.last_date_interesting).to eq Date.today
    end
  end

  context 'When article is marked interesting until yesterday or even sooner' do
    before do
      article.update!(last_date_interesting: Date.yesterday)
    end

    it 'Sets last_date_interesting to 5 days from now' do
      pin_article

      expect(article.reload.last_date_interesting).to eq (Date.today + 5.days)
    end
  end
end

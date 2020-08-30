require 'rails_helper'

describe 'Sessions', :type => :request do
  describe 'GET /sessions/new' do
    subject { get '/sessions/new' }

    it 'Renders new template' do
      subject

      expect(response).to render_template(:new)
    end
  end

  describe 'Logging in' do
    # skip
  end

  describe 'Logging out' do
    # skip
  end
end

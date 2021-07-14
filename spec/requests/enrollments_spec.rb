require 'rails_helper'
require 'requests/requests_spec_helper'

include RequestsSpecHelper

RSpec.describe "Enrollments", type: :request do
  let!(:season) { create(:season) }
  let!(:user) { create(:user) }

  describe "GET /enrollments" do
    subject { get enrollments_path }

    it "Renders index template and responds with success" do
      subject

      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end
end

require 'rails_helper'
require 'requests/authentication_helper'

include AuthenticationHelper

RSpec.describe "Enrollments", type: :request do
  let!(:season) { create(:season) }
  let!(:user) { create(:user) }

  describe "GET /enrollments" do
    subject(:get_enrollments) { get enrollments_path }

    it "Renders index template and responds with success" do
      get_enrollments

      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end
  
  describe "GET /enrollments/new" do
    subject(:get_enrollments_new) { get new_enrollment_path }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "Returns a success response" do
        get_enrollments_new

        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_enrollments_new

        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /enrollments" do
    subject(:post_enrollments) { post enrollments_path, params: params }

    let!(:category) { create(:category) }
    let!(:round1) { create(:round, season: season) }
    let!(:round2) { create(:round, season: season) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      context 'Enrolling existing player with valid params' do
        let!(:player) { create(:player) }
        let(:params) do
          { enrollment: { player_id: player.id } }
        end

        it "Does not create new player" do
          expect { post_enrollments }.not_to change(Player, :count)
        end

        it 'Calls EnrollPlayerToSeason with correct parameters' do
          expect(EnrollPlayerToSeason).to receive(:call)
                                              .with(player.id, season)
                                              .and_return(double('service_object', result: Enrollment.new))

          post_enrollments
        end

        it "Redirects to list of enrollments" do
          post_enrollments

          expect(response).to redirect_to enrollments_path
        end
      end

      context 'Enrolling new player with valid params' do
        let(:params) do
          { first_name: 'Roger', last_name: 'Federer', category_id: category.id }
        end

        it 'Creates new player' do
          post_enrollments
          created_player = Player.find_by(
              first_name: 'Roger',
              last_name: 'Federer',
              category: category
          )

          expect(created_player).not_to be(nil)
        end

        it 'Calls EnrollPlayerToSeason with correct parameters' do
          expect(Player).to receive(:create).and_return(instance_double('player', id: 'abc', 'persisted?' => true))
          expect(EnrollPlayerToSeason).to receive(:call).with('abc', season)

          post_enrollments
        end

        it "Redirects to list of enrollments" do
          post_enrollments

          expect(response).to redirect_to enrollments_path
        end

      end

      context 'Enrolling existing player with invalid params' do
        let(:params) do
          { enrollment: {} }
        end

        it 'Does not call EnrollPlayerToSeason' do
          expect(EnrollPlayerToSeason).not_to receive(:call)

          post_enrollments
        end

        it "Does not create new player/enrollment and renders new template" do
          expect { post_enrollments }.not_to change(Player, :count)
          expect { post_enrollments }.not_to change(Enrollment, :count)
          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end

      context 'Enrolling new player with invalid params' do
        let(:params) do
          { first_name: 'Roger', last_name: 'Federer', consent_given: false }
        end

        it 'Does not call EnrollPlayerToSeason' do
          expect(EnrollPlayerToSeason).not_to receive(:call)

          post_enrollments
        end

        it "Does not create new player/enrollment and renders new template" do
          expect{ post_enrollments }.not_to change(Player, :count)
          expect{ post_enrollments }.not_to change(Enrollment, :count)
          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'When logged out' do
      let!(:player) { create(:player) }
      let(:params) do
        { enrollment: { player_id: player.id } }
      end

      it 'Redirects to login' do
        post_enrollments

        expect(response).to redirect_to login_path
      end

      it 'Does not create new player/enrollment' do
        expect { post_enrollments }.not_to change(Player, :count)
        expect { post_enrollments }.not_to change(Enrollment, :count)
      end
    end
  end

  describe "GET /enrollments/:id/cancel" do
    subject(:cancel_enrollment) { get cancel_enrollment_path(enrollment) }

    let!(:enrollment) { create(:enrollment) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it 'Sets enrollment canceled' do
        cancel_enrollment

        expect(enrollment.reload.canceled?).to be(true)
      end

      it 'Redirects to the list of enrollments' do
        cancel_enrollment

        expect(response).to redirect_to(enrollments_path)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        cancel_enrollment

        expect(response).to redirect_to login_path
      end

      it 'Does not cancel the enrollment' do
        cancel_enrollment

        expect(enrollment.reload.canceled?).to be(false)
      end
    end
  end
end

require 'rails_helper'
require 'requests/requests_spec_helper'

Dir["./spec/requests/manager/shared_examples/*.rb"].sort.each { |f| require f }

include RequestsSpecHelper


RSpec.describe "Enrollments", type: :request do
  let!(:season) { create(:season) }
  let!(:user) { create(:user) }


  describe "GET /manager/enrollments/new" do
    subject { get new_manager_enrollment_path }

    it_behaves_like "manager_request_new"
  end


  describe "POST /manager/enrollments" do
    subject { post manager_enrollments_path, params: params }

    let!(:category) { create(:category) }
    let!(:round1) { create(:round, season: season) }
    let!(:round2) { create(:round, season: season) }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      context 'Enrolling existing player with valid params' do
        let!(:player) { create(:player) }
        let(:params) do
          { enrollment: { player_id: player.id } }
        end

        it "Does not create new player" do
          expect { subject }.not_to change(Player, :count)
        end

        it 'Calls EnrollPlayerToSeason with correct parameters' do
          expect(EnrollPlayerToSeason).to receive(:call)
                                            .with(player.id, season)
                                            .and_return(double('service_object', result: Enrollment.new))

          subject
        end

        it "Redirects to list of enrollments" do
          subject

          expect(response).to redirect_to enrollments_path
        end
      end

      context 'Enrolling new player with valid params' do
        let(:params) do
          { first_name: 'Roger', last_name: 'Federer', category_id: category.id }
        end

        it 'Creates new player' do
          subject

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

          subject
        end

        it "Redirects to list of enrollments" do
          subject

          expect(response).to redirect_to enrollments_path
        end

      end

      context 'Enrolling existing player with invalid params' do
        let(:params) do
          { enrollment: {} }
        end

        it 'Does not call EnrollPlayerToSeason' do
          expect(EnrollPlayerToSeason).not_to receive(:call)

          subject
        end

        it "Does not create new player/enrollment and renders new template" do
          expect { subject }.not_to change(Player, :count)
          expect { subject }.not_to change(Enrollment, :count)
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

          subject
        end

        it "Does not create new player/enrollment and renders new template" do
          expect{ subject }.not_to change(Player, :count)
          expect{ subject }.not_to change(Enrollment, :count)
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

      it 'Does not create new player/enrollment and redirects to login' do
        expect { subject }.not_to change(Player, :count)
        expect { subject }.not_to change(Enrollment, :count)

        expect(response).to redirect_to login_path
      end
    end
  end


  describe "GET /manager/enrollments/:id/cancel" do
    subject { get cancel_manager_enrollment_path(enrollment) }

    let!(:enrollment) { create(:enrollment) }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it 'Sets enrollment canceled and redirects to list of enrollments' do
        subject

        expect(enrollment.reload.canceled?).to be(true)
        expect(response).to redirect_to(enrollments_path)
      end
    end

    context 'When logged out' do
      it 'Does not cancel the enrollment and redirects to login' do
        subject

        expect(enrollment.reload.canceled?).to be(false)
        expect(response).to redirect_to login_path
      end
    end
  end
end
shared_examples "manager_request_index" do

  context "When signed in as a user" do

    before(:each) do
      requests_login(user, 'password')
    end

    it "Renders index template and responds with success" do
      subject

      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end

  context "Signed out" do
    it 'Redirects to login' do
      subject

      expect(response).to redirect_to login_path
    end
  end
end


shared_examples_for "manager_request_show" do

end


shared_examples_for "manager_request_new" do

  context "When signed in as a user" do

    before(:each) do
      requests_login(user, 'password')
    end

    it "Renders new template and responds with success" do
      subject

      expect(response).to render_template(:new)
      expect(response).to have_http_status(200)
    end
  end

  context "Signed out" do
    it 'Redirects to login' do
      subject

      expect(response).to redirect_to login_path
    end
  end
end

shared_examples_for "manager_request_create" do

  context "When signed in as a user" do

    before do
      requests_login(user, 'password')
    end

    context "With valid params" do
      let(:params) { valid_params }

      it "Creates new record" do
        expect { subject }.to change{model.count}.by(1)
      end
    end

    context "With invalid params" do
      let(:params) { invalid_params }

      it "Renders new template" do
        expect(subject).to render_template(:new)
      end
    end
  end

  context "Signed out" do
    let(:params) { valid_params }

    it 'Redirects to login' do
      subject

      expect(response).to redirect_to login_path
    end
  end

end

shared_examples_for "manager_request_edit" do

  context "When signed in as a user" do
    before(:each) do
      requests_login(user, 'password')
    end

    it "Returns a success response" do
      subject

      expect(response).to render_template(:edit)
      expect(response).to have_http_status(200)
    end
  end

  context "Signed out" do
    it 'Redirects to login' do
      subject

      expect(response).to redirect_to login_path
    end
  end
end


shared_examples_for "manager_request_update" do

  context 'When signed in as a user' do
    before(:each) do
      requests_login(user, 'password')
    end

    context "With valid params" do
      let(:params) { valid_params }

      it "Updates the record" do
        subject

        record.reload
        expect(record).to have_attributes(valid_params[model.to_s.underscore.to_sym])
      end
    end

    context "With invalid params" do
      let(:params) { invalid_params }

      it "Renders edit template" do
        expect(subject).to render_template(:edit)
      end
    end
  end

  context 'Signed out' do

    let(:params) { valid_params }

    it 'Does not update record and redirects to login' do
      subject

      record.reload
      expect(record).not_to have_attributes(valid_params[model.to_s.underscore.to_sym])
      expect(response).to redirect_to login_path
    end
  end

end

shared_examples_for "manager_request_destroy" do

  context "When signed in as a user" do
    before(:each) do
      requests_login(user, 'password')
    end

    it "Destroys given season and redirects" do
      id = record.id
      subject

      expect(model.find_by(id: id)).to be_nil
      expect(response).to redirect_to redirect_path
    end
  end

  context "Signed out" do
    it 'Does not destroy record and redirects to login' do
      expect { subject }.not_to change(model, :count)

      expect(response).to redirect_to login_path
    end
  end
end

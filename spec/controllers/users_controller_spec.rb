require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  controller do
  end

  context 'when updating a User' do
    it 'sets the correct updater' do
      request.session = { user_id: @hera.id }
      patch :update, params: { id: @hera.id, user: { name: 'Different'} }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@user).name).to eq('Different')
      expect(controller.instance_variable_get(:@user).updater).to eq(@hera)
    end
  end

  context 'when handling multiple requests' do
    def simulate_second_request
      old_request_session = request.session
      request.session = { user_id: @zeus.id }

      post :update, params: { id: @hera.id, user: { name: 'Different Second' } }
      expect(controller.instance_variable_get(:@user).updater).to eq(@zeus)
    ensure
      request.session = old_request_session
    end

    it 'sets the correct updater' do
      request.session = { user_id: @hera.id }
      get :edit, params: { id: @hera.id }
      expect(response.status).to eq(200)

      simulate_second_request
    end
  end

  context 'when the handler raises an exception' do
    before { @stamper = User.stamper }
    it 'restores the correct stamper' do
      begin
        request.session = { user_id: @zeus.id }
        post :create
      rescue
      end

      expect(User.stamper).to be(@stamper)
    end
  end
end

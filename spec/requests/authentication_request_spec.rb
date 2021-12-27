# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentications', type: :request do
  describe 'endpoint call' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'with authorization token' do
      it 'should works well' do
        get '/api/v1/clients', headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(200)
      end
    end

    context 'with expired authorization token' do
      let(:token) { AuthenticationTokenService.call(user.id, Time.now.to_i - 1) }

      it 'should warn the user token expired' do
        get '/api/v1/clients', headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(401)
        expect(response.body).to eq(
          { error: 'User token expired' }.to_json
        )
      end
    end

    context 'with wrong token type' do
      it 'should warn wrong token' do
        get '/api/v1/clients', headers: {
          Authorization: "Barer #{token}"
        }

        expect(response).to have_http_status(401)
        expect(response.body).to eq(
          { error: 'Wrong token' }.to_json
        )
      end
    end

    context 'without authorization token' do
      it 'should warn user unauthenticated' do
        get '/api/v1/clients'

        expect(response).to have_http_status(401)
        expect(response.body).to eq(
          { error: 'User unauthenticated' }.to_json
        )
      end
    end
  end
end

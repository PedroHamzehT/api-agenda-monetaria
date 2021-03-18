require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe 'POST /api/v1/sign_up' do
    context 'valid parameters' do
      it 'should return created status' do
        post '/api/v1/sign_up', params: {
          user: { name: 'User', email: 'user@example.com', password: 'password', password_confirmation: 'password' }
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a user' do
        post '/api/v1/sign_up', params: {
          user: { name: 'User', email: 'user@example.com', password: 'password', password_confirmation: 'password' }
        }

        expect(User.count).to eq(1)
        expect(User.last.email).to eq('user@example.com')
      end

      it 'should return a token' do
        post '/api/v1/sign_up', params: {
          user: { name: 'User', email: 'user@example.com', password: 'password', password_confirmation: 'password' }
        }

        api_result = JSON.parse(response.body)
        decoded_token = JWT.decode(
          api_result['token'],
          AuthenticationTokenService::HMAC_SECRET,
          true,
          { algorithm: AuthenticationTokenService::ALGORITHM_TYPE }
        )

        expect(decoded_token).to eq(
          [
            { 'user_id' => User.last.id },
            { 'alg' => 'HS256' }
          ]
        )
      end
    end

    context 'invalid parameters' do
      it 'should return bad request status' do
        post '/api/v1/sign_up', params: {
          user: { name: nil, email: nil, password: nil, password_confirmation: nil }
        }

        expect(response).to have_http_status(400)
      end

      it 'should warn when email is missing' do
        post '/api/v1/sign_up', params: {
          user: { name: 'User', email: nil, password: 'password', password_confirmation: 'password' }
        }

        expect(response.body).to include("Email can't be blank")
      end

      it 'should warn when name is missing' do
        post '/api/v1/sign_up', params: {
          user: { name: nil, email: 'user@example.com', password: 'password', password_confirmation: 'password' }
        }

        expect(response.body).to include("Name can't be blank")
      end

      it 'should warn when password is missing' do
        post '/api/v1/sign_up', params: {
          user: { name: 'User', email: 'user@example.com', password: nil, password_confirmation: nil }
        }

        expect(response.body).to include("Password can't be blank")
      end

      it 'should warn when email already exists' do
        create(:user, email: 'user@example.com')

        post '/api/v1/sign_up', params: {
          user: { name: 'User', email: 'user@example.com', password: 'password', password_confirmation: 'password' }
        }

        expect(response.body).to include('Email has already been taken')
      end

      it 'should warn when password and password confirmation are not matching' do
        post '/api/v1/sign_up', params: {
          user: { name: 'User', email: 'user@example.com', password: 'password', password_confirmation: 'p@ssword' }
        }

        expect(response.body).to include("Password confirmation doesn't match Password")
      end
    end
  end

  describe 'POST /api/v1/sign_in' do
    let(:user) { create(:user, email: 'user@example.com', password: 'password', password_confirmation: 'password') }

    context 'valid parameters' do
      it 'should return success status' do
        get '/api/v1/sign_in', headers: {
          email: Base64.encode64(user.email),
          password: Base64.encode64('password')
        }

        expect(response).to have_http_status(200)
      end

      it 'should find the user and return a token' do
        get '/api/v1/sign_in', headers: {
          email: Base64.encode64(user.email),
          password: Base64.encode64('password')
        }

        expect(response.body).to eq(
          { token: AuthenticationTokenService.call(user.id) }.to_json
        )
      end
    end

    context 'inavlid parameters' do
      it 'should return bad request status' do
        get '/api/v1/sign_in'

        expect(response).to have_http_status(400)
      end

      context 'when password is incorrect' do
        it 'should warn email and/or password are incorrect' do
          get '/api/v1/sign_in', headers: {
            email: Base64.encode64(user.email),
            password: Base64.encode64('123')
          }

          expect(response.body).to eq(
            { error: 'Email and/or password are incorrect' }.to_json
          )
        end
      end

      context 'when email is incorrect' do
        it 'should warn email and/or password are incorrect' do
          get '/api/v1/sign_in', headers: {
            email: Base64.encode64('u@example.com'),
            password: Base64.encode64('password')
          }

          expect(response.body).to eq(
            { error: 'Email and/or password are incorrect' }.to_json
          )
        end
      end
    end
  end

  describe 'PUT /api/v1/user' do
    context 'valid parameters' do
      it 'should return success status'

      it 'should update the user'
    end

    context 'invalid parameters' do
      it 'should return bad request status'

      it 'should warn when email already exists'
    end
  end
end

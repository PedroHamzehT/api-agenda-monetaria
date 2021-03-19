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
            { 'exp' => Time.now.to_i + 4 * 3600, 'user_id' => User.last.id },
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
          email: user.email,
          password: Base64.encode64('password')
        }

        expect(response).to have_http_status(200)
      end

      it 'should find the user and return a token' do
        get '/api/v1/sign_in', headers: {
          email: user.email,
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
            email: user.email,
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
            email: 'u@example.com',
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
    let(:user) { create(:user, name: 'User', email: 'user@example.com', password: 'password', password_confirmation: 'password') }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should return success status' do
        put '/api/v1/user', headers: {
          Authorization: "Bearer #{token}"
        }, params: {
          user: {
            name: 'User 2'
          }
        }

        expect(response).to have_http_status(200)
      end

      it 'should update the user' do
        put '/api/v1/user', headers: {
          Authorization: "Bearer #{token}"
        }, params: {
          user: {
            name: 'User 2'
          }
        }

        expect(User.last.name).to eq('User 2')
      end
    end

    context 'invalid parameters' do
      it 'should return bad request status' do
        put '/api/v1/user', headers: {
          Authorization: "Bearer #{token}"
        }, params: {
          user: {
            name: nil,
            email: nil
          }
        }

        expect(response).to have_http_status(400)
      end

      it 'should warn when email already exists' do
        create(:user, email: 'user2@example.com')

        put '/api/v1/user', headers: {
          Authorization: "Bearer #{token}"
        }, params: {
          user: {
            email: 'user2@example.com'
          }
        }

        expect(response.body).to eq(
          { error: ['Email has already been taken'] }.to_json
        )
      end

      it 'should warn when user is unauthenticated' do
        put '/api/v1/user', params: {
          user: {
            email: 'user2@example.com'
          }
        }

        expect(response).to have_http_status(401)
        expect(response.body).to eq(
          { error: 'User unauthenticated' }.to_json
        )
      end
    end
  end

  describe 'PUT /api/v1/user/reset_password' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should change the password successfuly' do
        put '/api/v1/user/reset_password', params: {
          user: { password: 'new_password', password_confirmation: 'new_password' }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        user = User.last.authenticate('new_password')
        expect(response).to have_http_status(200)
        expect(user).to be_truthy
      end
    end

    context 'invalid parameters' do
      it 'should warn when user is unauthenticated' do
        put '/api/v1/user/reset_password', params: {
          user: { password: 'new_password', password_confirmation: 'new_password' }
        }

        expect(response).to have_http_status(401)
        expect(response.body).to eq(
          { error: 'User unauthenticated' }.to_json
        )
      end

      it 'should warn when the passwords do not match' do
        put '/api/v1/user/reset_password', params: {
          user: { password: 'new_password', password_confirmation: 'different_new_password' }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(400)
        expect(response.body).to eq(
          { error: ["Password confirmation doesn't match Password"] }.to_json
        )
      end
    end
  end
end

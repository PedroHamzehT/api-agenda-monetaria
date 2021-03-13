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

      it 'should create a user'

      it 'should return a token'
    end

    context 'invalid parameters' do
      it 'should return bad request status'

      it 'should warn when email is missing'

      it 'should warn when name is missing'

      it 'should warn when password is missing'

      it 'should warn when email already exists'

      it 'should warn when password and password confirmation are not matching'
    end
  end

  describe 'POST /api/v1/sign_in' do
    context 'valid parameters' do
      it 'should return success status'

      it 'should find the user and return a token'
    end

    context 'inavlid parameters' do
      it 'should return bad request status'

      it 'should warn when password is missing'

      it 'should warn when email already exists'

      it 'should warn when email not found'

      it 'should warn when password not found with the email'
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

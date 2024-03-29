# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clients', type: :request do
  describe 'GET /api/v1/clients' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    it 'should return success status' do
      get '/api/v1/clients', headers: {
        Authorization: "Bearer #{token}"
      }

      expect(response).to have_http_status(200)
    end

    it 'should return a clients list with them infos' do
      clients = create_list(:client, 3, user_id: user.id)

      get '/api/v1/clients', headers: {
        Authorization: "Bearer #{token}"
      }

      clients.each do |client|
        expect(response.body).to include(client.name)
        expect(response.body).to include(client.email)
        expect(response.body).to include(client.cellphone.to_s)
        expect(response.body).to include(client.description)
      end
    end

    it 'should return only twenty clients per page' do
      create_list(:client, 25, user_id: user.id)

      get '/api/v1/clients', headers: {
        Authorization: "Bearer #{token}"
      }

      expect(JSON.parse(response.body).count).to eq(20)
    end

    it 'should warn when user is unauthenticated' do
      create_list(:client, 3, user_id: user.id)

      get '/api/v1/clients'

      expect(response).to have_http_status(401)
      expect(response.body).to eq(
        { error: 'User unauthenticated' }.to_json
      )
    end
  end

  describe 'POST /api/v1/clients' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should return created status' do
        client_attributes = FactoryBot.attributes_for(:client, user_id: user.id)

        post '/api/v1/clients', params: {
          client: client_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a client' do
        client_attributes = FactoryBot.attributes_for(:client, user_id: user.id)

        post '/api/v1/clients', params: {
          client: client_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(Client.last).to have_attributes(client_attributes)
      end
    end

    context 'invalid parameters' do
      it 'should not create a client' do
        expect do
          post '/api/v1/clients', params: {
            client: { name: '', email: '', cellphone: '', description: '' }, headers: {
              Authorization: "Bearer #{token}"
            }
          }
        end.to_not change(Client, :count)
      end

      it 'should warn when user is unauthenticated' do
        post '/api/v1/clients', params: {
          client: { name: '', email: '', cellphone: '', description: '' }
        }

        expect(response).to have_http_status(401)
        expect(response.body).to eq(
          { error: 'User unauthenticated' }.to_json
        )
      end
    end
  end

  describe 'PUT /api/v1/clients/:id' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should return success status' do
        client = create(:client, user_id: user.id)

        put "/api/v1/clients/#{client.id}", params: {
          client: { name: 'Kleber' }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(200)
      end

      it 'should update the clients info' do
        client = create(:client, user_id: user.id)

        put "/api/v1/clients/#{client.id}", params: {
          client: { name: 'Kleber' }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(Client.last.name).to eq('Kleber')
      end
    end

    context 'invalid parameters' do
      it 'should not edit the client' do
        client = create(:client, user_id: user.id)

        put "/api/v1/clients/#{client.id}", params: {
          client: { name: '', email: '' }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(Client.last.name).to eq(client.name)
        expect(Client.last.email).to eq(client.email)
      end

      it 'should return client not found error' do
        put '/api/v1/clients/999', params: {
          client: { name: 'Kleber' }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response.body).to include('Client not found')
      end

      it 'should warn when user is unauthenticated' do
        put '/api/v1/clients/999', params: {
          client: { name: 'Kleber' }
        }

        expect(response).to have_http_status(401)
        expect(response.body).to eq(
          { error: 'User unauthenticated' }.to_json
        )
      end
    end
  end

  describe 'GET /api/v1/clients/:id/sales' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid client id' do
      it 'should return success status' do
        client = create(:client, user_id: user.id)
        create(:sale, client_id: client.id)

        get "/api/v1/clients/#{client.id}/sales", headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(200)
      end

      it 'should return a clients sales list' do
        client = create(:client, user_id: user.id)
        create_list(:sale, 3)
        sales = create_list(:sale, 3, client_id: client.id)

        get "/api/v1/clients/#{client.id}/sales", headers: {
          Authorization: "Bearer #{token}"
        }

        api_result = JSON.parse response.body
        expect(api_result.size).to eq(3)

        sales.each do |sale|
          expect(response.body).to include(sale.paid.to_s)
          expect(response.body).to include(sale.tax.to_s)
          expect(response.body).to include(sale.parcelling.to_s)
          expect(response.body).to include(sale.sale_date.strftime('%d/%m/%Y'))
        end
      end
    end

    context 'invalid client id' do
      it 'should return client not found error' do
        get '/api/v1/clients/999/sales', headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response.body).to include('Client not found')
      end
    end

    it 'should warn when user is unauthenticated' do
      get '/api/v1/clients/1/sales'

      expect(response).to have_http_status(401)
      expect(response.body).to eq(
        { error: 'User unauthenticated' }.to_json
      )
    end
  end
end

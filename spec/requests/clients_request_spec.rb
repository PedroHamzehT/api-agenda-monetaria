require 'rails_helper'

RSpec.describe "Clients", type: :request do
  describe 'GET /clients' do
    it 'should return success status' do
      get '/clients'

      expect(response).to have_http_status(200)
    end

    it 'should return a clients list with them infos' do
      create(:client)
      create(:client)

      get '/clients'

      api_result = JSON.parse response.body

      expect(api_result.is_Array?).to eq(true)
      # To finish need to check if the api_result client match with client in db
    end
  end

  describe 'POST /clients' do
    it 'should return success status' do
      client_attributes = FactoryBot.attributes_for(:client)

      post '/clients', params: {
        client: client_attributes
      }

      expect(response).to have_http_status(200)
    end

    it 'should create a client' do
      client_attributes = FactoryBot.attributes_for(:client)

      post '/clients', params: {
        client: client_attributes
      }

      expect(Client.last).to have_attributes(client_attributes)
    end
  end

  describe 'PUT /clients/:id' do
    it 'should return success status' do
      client = create(:client)

      put "/clients/#{client.id}", params: {
        client: { name: 'Kleber' }
      }

      expect(response).to have_http_status(200)
    end

    it 'should update the clients info' do
      client = create(:client)

      put "/clients/#{client.id}", params: {
        client: { name: 'Kleber' }
      }

      expect(Client.last.name).to eq('Kleber')
    end
  end

  describe 'GET /clients/:id/sales' do
    it 'should return success status' do
      client = create(:sale).client

      get "/clients/#{client.id}/sales"

      expect(response).to have_http_status(200)
    end

    it 'should return a clients sales list' do
      sale = create(:sale)
      create(:sale, client_id: sale.client_id)

      get "/clients/#{client.id}/sales"

      api_result = JSON.parse response.body
      expect(api_result.is_Array?).to eq(true)
      # To finish need to check if the api_result sale match with sale in db
    end
  end
end

require 'rails_helper'

RSpec.describe "Clients", type: :request do
  describe 'GET /clients' do
    it 'should return success status' do
      get '/clients'

      expect(response).to have_http_status(200)
    end

    it 'should return a clients list with them infos' do
      clients = create_list(:client, 3)

      get '/clients'

      clients.each do |client|
        expect(response.body).to include(client.name)
        expect(response.body).to include(client.email)
        expect(response.body).to include(client.cellphone)
        expect(response.body).to include(client.description)
      end
    end
  end

  describe 'POST /clients' do
    context 'valid parameters' do
      it 'should return created status' do
        client_attributes = FactoryBot.attributes_for(:client)

        post '/clients', params: {
          client: client_attributes
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a client' do
        client_attributes = FactoryBot.attributes_for(:client)

        post '/clients', params: {
          client: client_attributes
        }

        expect(Client.last).to have_attributes(client_attributes)
      end
    end

    context 'invalid parameters' do
      expect {
        post '/clients', params: {
          client: { name: '', email: '', cellphone: '', description: '' }
        }
      }.to_not change(Client, :count)
    end
  end

  describe 'PUT /clients/:id' do
    context 'valid parameters' do
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

    context 'invalid parameters' do
      it 'should not edit the client' do
        client = create(:client)

        put "/clients/#{client.id}", params: {
          client: { name: '', email: '' }
        }

        expect(Client.last.name).to eq(client.name)
        expect(Client.last.email).to eq(client.email)
      end
    end
  end

  describe 'GET /clients/:id/sales' do
    it 'should return success status' do
      client = create(:sale).client

      get "/clients/#{client.id}/sales"

      expect(response).to have_http_status(200)
    end

    it 'should return a clients sales list' do
      client = create(:client)
      create_list(:sale, 3)
      sales = create_list(:sale, 3, client_id: client.id)

      get "/clients/#{client.id}/sales"

      api_result = JSON.parse response.body
      expect(api_result.size).to eq(3)

      sales.each do |sale|
        expect(response.body).to include(sale.paid)
        expect(response.body).to include(sale.tax)
        expect(response.body).to include(sale.parcelling)
        expect(response.body).to include(sale.sale_date)
      end
    end
  end
end

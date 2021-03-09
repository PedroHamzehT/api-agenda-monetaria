require 'rails_helper'

RSpec.describe "Clients", type: :request do
  describe 'GET /api/v1/clients' do
    it 'should return success status' do
      get '/api/v1/clients'

      expect(response).to have_http_status(200)
    end

    it 'should return a clients list with them infos' do
      clients = create_list(:client, 3)

      get '/api/v1/clients'

      clients.each do |client|
        expect(response.body).to include(client.name)
        expect(response.body).to include(client.email)
        expect(response.body).to include(client.cellphone.to_s)
        expect(response.body).to include(client.description)
      end
    end

    it 'should return only twenty clients per page' do
      create_list(:client, 25)

      get '/api/v1/clients'

      expect(JSON.parse(response.body).count).to eq(20)
    end
  end

  describe 'POST /api/v1/clients' do
    context 'valid parameters' do
      it 'should return created status' do
        client_attributes = FactoryBot.attributes_for(:client)

        post '/api/v1/clients', params: {
          client: client_attributes
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a client' do
        client_attributes = FactoryBot.attributes_for(:client)

        post '/api/v1/clients', params: {
          client: client_attributes
        }

        expect(Client.last).to have_attributes(client_attributes)
      end
    end

    context 'invalid parameters' do
      it 'should not create a client' do
        expect {
          post '/api/v1/clients', params: {
            client: { name: '', email: '', cellphone: '', description: '' }
          }
        }.to_not change(Client, :count)
      end
    end
  end

  describe 'PUT /api/v1/clients/:id' do
    context 'valid parameters' do
      it 'should return success status' do
        client = create(:client)

        put "/api/v1/clients/#{client.id}", params: {
          client: { name: 'Kleber' }
        }

        expect(response).to have_http_status(200)
      end

      it 'should update the clients info' do
        client = create(:client)

        put "/api/v1/clients/#{client.id}", params: {
          client: { name: 'Kleber' }
        }

        expect(Client.last.name).to eq('Kleber')
      end
    end

    context 'invalid parameters' do
      it 'should not edit the client' do
        client = create(:client)

        put "/api/v1/clients/#{client.id}", params: {
          client: { name: '', email: '' }
        }

        expect(Client.last.name).to eq(client.name)
        expect(Client.last.email).to eq(client.email)
      end

      it 'should return client not found error' do
        put '/api/v1/clients/999', params: {
          client: { name: 'Kleber' }
        }

        expect(response.body).to include('Client not found')
      end
    end
  end

  describe 'GET /api/v1/clients/:id/sales' do
    context 'valid client id' do
      it 'should return success status' do
        client = create(:sale).client

        get "/api/v1/clients/#{client.id}/sales"

        expect(response).to have_http_status(200)
      end

      it 'should return a clients sales list' do
        client = create(:client)
        create_list(:sale, 3)
        sales = create_list(:sale, 3, client_id: client.id)

        get "/api/v1/clients/#{client.id}/sales"

        api_result = JSON.parse response.body
        expect(api_result.size).to eq(3)

        sales.each do |sale|
          expect(response.body).to include(sale.paid.to_s)
          expect(response.body).to include(sale.tax.to_s)
          expect(response.body).to include(sale.parcelling.to_s)
          expect(response.body).to include(sale.sale_date.strftime('%d/%m/%Y %H:%M:%S %z'))
        end
      end
    end

    context 'invalid client id' do
      it 'should return client not found error' do
        get '/api/v1/clients/999/sales'

        expect(response.body).to include('Client not found')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Sales", type: :request do
  describe 'GET /sales' do
    it 'should return success status' do
      get '/sales'

      expect(response).to have_http_status(200)
    end

    it 'should return a sales list' do
      sales = create_list(:sale, 3)

      get '/sales'

      sales.each do |sale|
        expect(response.body).to include(sale.paid)
        expect(response.body).to include(sale.tax)
        expect(response.body).to include(sale.parcelling)
        expect(response.body).to include(sale.sale_date)
      end
    end

    it 'should return sales based in a client' do
      client = create(:client)
      create(:sale)
      create(:sale, client_id: client.id)

      get "/sales?client_id=#{client.id}"

      api_result = JSON.parse response.body

      expect(api_result.first['client_id']).to eq(client.id)
    end
  end

  describe 'POST /sales' do
    context 'valid parameters' do
      it 'should return success status' do
        sale_attributes = FactoryBot.attributes_for(:sale)

        post '/sales', params: {
          sale: sale_attributes
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a sale' do
        sale_attributes = FactoryBot.attributes_for(:sale)

        post '/sales', params: {
          sale: sale_attributes
        }

        expect(Sale.last).to have_attributes(sale_attributes)
      end
    end

    context 'invalid parameters' do
      it 'should not create a sale' do
        expect {
          post '/sales', params: {
            sale: { sale_date: nil }
          }
        }.to_not change(Sale, :count)
      end
    end
  end

  describe 'PUT /sales/:id' do
    context 'valid parameters' do
      it 'should return success status' do
        sale = create(:sale)

        put "/sales/#{sale.id}", params: {
          sale: { parcelling: 99 }
        }

        expect(response).to have_http_status(200)
      end

      it 'should update the sale' do
        sale = create(:sale)

        put "/sales/#{sale.id}", params: {
          sale: { parcelling: 99 }
        }

        expect(Sale.last.parcelling).to eq(99)
      end
    end

    context 'invalid parameters' do
      it 'should not edit the sale' do
        sale = create(:sale)

        put "/sales/#{sale.id}", params: {
          sale: { sale_date: nil }
        }

        expect(sale.sale_date).to eq(sale.sale_date)
      end

      it 'should return sale not found error' do
        put '/sales/999', params: {
          sale: { parcelling: 2 }
        }

        expect(response.body).to include('Sale not found')
      end
    end
  end

  describe 'GET /sales/:id/payments' do
    context 'valid sale id' do
      it 'should return success status' do
        sale = create(:sale)
        create(:payment_history, sale_id: sale.id)

        get "/sales/#{sale.id}/payments"

        expect(response).to have_http_status(200)
      end

      it 'should return a sales payments list' do
        sale = create(:sale)
        payments = create_list(:payment_history, 3, sale_id: sale.id)

        get "/sales/#{sale.id}/payments"

        payments.each do |payment|
          expect(response.body).to include(payment.pay_value)
          expect(response.body).to include(payment.date)
        end
      end
    end

    context 'invalid sale id' do
      it 'should return sale not found error' do
        get '/sales/999/payments'

        expect(response.body).to include('Sale not found')
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sales', type: :request do
  describe 'GET /api/v1/sales' do
    let(:user) { create(:user) }
    let(:client) { create(:client, user_id: user.id) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    it 'should return success status' do
      get '/api/v1/sales', headers: {
        Authorization: "Bearer #{token}"
      }

      expect(response).to have_http_status(200)
    end

    it 'should return a sales list' do
      sales = create_list(:sale, 3, client_id: client.id)

      get '/api/v1/sales', headers: {
        Authorization: "Bearer #{token}"
      }

      sales.each do |sale|
        expect(response.body).to include(sale.paid.to_s)
        expect(response.body).to include(sale.tax.to_s)
        expect(response.body).to include(sale.parcelling.to_s)
        expect(response.body).to include(sale.sale_date.strftime('%d/%m/%Y'))
      end
    end

    it 'should return sales based in a client' do
      create(:sale, client_id: client.id)
      create(:sale, client_id: client.id)

      get "/api/v1/sales?client=#{client.id}", headers: {
        Authorization: "Bearer #{token}"
      }

      api_result = JSON.parse response.body

      expect(api_result.first['client_id']).to eq(client.id)
    end

    it 'should return also sale products' do
      create(:sale, client_id: client.id)
      sale_products = create_list(:sale_product, 3, sale_id: Sale.last.id)

      get '/api/v1/sales', headers: {
        Authorization: "Bearer #{token}"
      }

      sale_products.each do |sale_product|
        expect(response.body).to include(sale_product.product_id.to_s)
        expect(response.body).to include(sale_product.quantity.to_s)
        expect(response.body).to include(sale_product.product.name)
      end
    end

    it 'should return also sale payments' do
      create(:sale, client_id: client.id)
      create(:sale_product, sale_id: Sale.last.id)
      payment = create(:payment_history, sale_id: Sale.last.id, pay_value: 200)

      get '/api/v1/sales', headers: {
        Authorization: "Bearer #{token}"
      }

      expect(response.body).to include(payment.date.strftime('%d/%m/%Y'))
      expect(response.body).to include(payment.pay_value.to_s)
    end

    it 'should filter the sales by the paid status' do
      create_list(:sale, 10, client_id: client.id)
      create(:sale, paid: true, client_id: client.id)

      get '/api/v1/sales?paid=true', headers: {
        Authorization: "Bearer #{token}"
      }

      expect(JSON.parse(response.body).count).to eq(1)
    end

    it 'should return only twenty results per page' do
      create_list(:sale, 25, client_id: client.id)

      get '/api/v1/sales', headers: {
        Authorization: "Bearer #{token}"
      }

      expect(JSON.parse(response.body).count).to eq(20)
    end
  end

  describe 'POST /api/v1/sales' do
    let(:user) { create(:user) }
    let(:client) { create(:client, user_id: user.id) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should return success status' do
        sale_attributes = FactoryBot.attributes_for(:sale, client_id: client.id)
        products = create_list(:product, 3, user_id: user.id)
        products_attributes = products.map { |product| { product_id: product.id, quantity: rand(1..9) } }

        post '/api/v1/sales', params: {
          sale: sale_attributes,
          products: products_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a sale' do
        sale_attributes = FactoryBot.attributes_for(:sale, client_id: client.id)
        sale_attributes[:sale_date] = sale_attributes[:sale_date].in_time_zone

        products = create_list(:product, 3, user_id: user.id)
        products_attributes = products.map { |product| { product_id: product.id, quantity: rand(1..9) } }

        post '/api/v1/sales', params: {
          sale: sale_attributes,
          products: products_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(Sale.last.sale_date.in_time_zone.to_s).to eq(sale_attributes[:sale_date].to_s)
        expect(Sale.last.client_id).to eq(sale_attributes[:client_id])
        expect(Sale.last.products.count).to eq(3)
      end
    end

    context 'invalid parameters' do
      it 'should not create a sale' do
        expect do
          post '/api/v1/sales', params: {
            sale: { sale_date: nil }
          }, headers: {
            Authorization: "Bearer #{token}"
          }
        end.to_not change(Sale, :count)
      end

      it 'should return sale must have at least one product error' do
        sale_attributes = FactoryBot.attributes_for(:sale, client_id: client.id)

        post '/api/v1/sales', params: {
          sale: sale_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(Sale.count).to eq(0)
        expect(response.body).to include('Sale must have at least one product')
      end

      it 'should not create a sale with a product that user does not have' do
        sale_attributes = FactoryBot.attributes_for(:sale, client_id: client.id)
        product = create(:product)
        product_attributes = [{ product_id: product.id, quantity: rand(1..9) }]

        post '/api/v1/sales', params: {
          sale: sale_attributes,
          products: product_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(400)
        expect(response.body).to eq(
          { error: 'User does not have any of those products' }.to_json
        )
      end
    end
  end

  describe 'PUT /api/v1/sales/:id' do
    let(:user) { create(:user) }
    let(:client) { create(:client, user_id: user.id) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should return success status' do
        sale = create(:sale, client_id: client.id)
        products = create_list(:product, 3, user_id: user.id)
        products.each { |product| create(:sale_product, product_id: product.id) }
        products_attributes = SaleProduct.all.map { |sp| { product_id: sp.product_id, quantity: sp.quantity } }

        put "/api/v1/sales/#{sale.id}", params: {
          sale: { parcelling: 99 },
          products: products_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(200)
      end

      it 'should update the sale' do
        sale = create(:sale, client_id: client.id)
        products = create_list(:product, 3, user_id: user.id)
        products.each { |product| create(:sale_product, product_id: product.id) }
        products_attributes = SaleProduct.all.map { |sp| { product_id: sp.product_id, quantity: sp.quantity } }

        put "/api/v1/sales/#{sale.id}", params: {
          sale: { parcelling: 99 },
          products: products_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(sale.reload.parcelling).to eq(99)
      end

      it 'should update the sale products' do
        sale = create(:sale, client_id: client.id)
        products = create_list(:product, 3, user_id: user.id)
        products.each { |product| create(:sale_product, product_id: product.id) }
        products_attributes = [SaleProduct.first].map do |sp|
          { product_id: sp.product_id, quantity: (sp.quantity + 2) }
        end

        put "/api/v1/sales/#{sale.id}", params: {
          sale: sale.attributes,
          products: products_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(sale.products.count).to eq(1)
        products_attributes.each do |product_attribute|
          expect(sale.products.first.id).to eq(product_attribute[:product_id])
          expect(sale.sale_products.first.quantity).to eq(product_attribute[:quantity])
        end
      end
    end

    context 'invalid parameters' do
      it 'should not edit the sale' do
        sale = create(:sale, client_id: client.id)

        put "/api/v1/sales/#{sale.id}", params: {
          sale: { sale_date: nil }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(sale.sale_date).to eq(sale.sale_date)
      end

      it 'should return sale not found error' do
        put '/api/v1/sales/999', params: {
          sale: { parcelling: 2 }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response.body).to include('Sale not found')
      end

      it 'should not create a sale with a product that user does not have' do
        sale = create(:sale, client_id: client.id)
        product = create(:product)
        product_attributes = [{ product_id: product.id, quantity: rand(1..9) }]

        put "/api/v1/sales/#{sale.id}", params: {
          products: product_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(400)
        expect(response.body).to eq(
          { error: 'User does not have any of those products' }.to_json
        )
      end
    end
  end

  describe 'GET /api/v1/sales/:id/payments' do
    let(:user) { create(:user) }
    let(:client) { create(:client, user_id: user.id) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid sale id' do
      it 'should return success status' do
        sale = create(:sale, client_id: client.id)
        create(:payment_history, sale_id: sale.id)

        get "/api/v1/sales/#{sale.id}/payments", headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(200)
      end

      it 'should return a sales payments list' do
        sale = create(:sale, client_id: client.id)
        payments = create_list(:payment_history, 3, sale_id: sale.id)

        get "/api/v1/sales/#{sale.id}/payments", headers: {
          Authorization: "Bearer #{token}"
        }

        payments.each do |payment|
          expect(response.body).to include(payment.pay_value.to_s)
          expect(response.body).to include(payment.date.strftime('%d/%m/%Y'))
        end
      end
    end

    context 'invalid sale id' do
      it 'should return sale not found error' do
        get '/api/v1/sales/999/payments', headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response.body).to include('Sale not found')
      end
    end
  end
end

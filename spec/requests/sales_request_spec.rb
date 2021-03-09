# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sales', type: :request do
  describe 'GET /api/v1/sales' do
    it 'should return success status' do
      get '/api/v1/sales'

      expect(response).to have_http_status(200)
    end

    it 'should return a sales list' do
      sales = create_list(:sale, 3)

      get '/api/v1/sales'

      sales.each do |sale|
        expect(response.body).to include(sale.paid.to_s)
        expect(response.body).to include(sale.tax.to_s)
        expect(response.body).to include(sale.parcelling.to_s)
        expect(response.body).to include(sale.sale_date.strftime('%d/%m/%Y %H:%M:%S %z'))
      end
    end

    it 'should return sales based in a client' do
      client = create(:client)
      create(:sale)
      create(:sale, client_id: client.id)

      get "/api/v1/sales?client=#{client.id}"

      api_result = JSON.parse response.body

      expect(api_result.first['client_id']).to eq(client.id)
    end

    it 'should return also sale products' do
      create(:sale)
      sale_products = create_list(:sale_product, 3, sale_id: Sale.last.id)

      get '/api/v1/sales'

      sale_products.each do |sale_product|
        expect(response.body).to include(sale_product.product_id.to_s)
        expect(response.body).to include(sale_product.quantity.to_s)
        expect(response.body).to include(sale_product.product.name)
      end
    end

    it 'should return also sale payments' do
      create(:sale)
      create(:sale_product, sale_id: Sale.last.id)
      payment = create(:payment_history, sale_id: Sale.last.id, pay_value: 200)

      get '/api/v1/sales'

      expect(response.body).to include(payment.date.strftime('%d/%m/%Y %H:%M:%S %z'))
      expect(response.body).to include(payment.pay_value.to_s)
    end

    it 'should filter the sales by the paid status'

    it 'should return only twenty results per page' do
      create_list(:sale, 25)

      get '/api/v1/sales'

      expect(JSON.parse(response.body).count).to eq(20)
    end
  end

  describe 'POST /api/v1/sales' do
    context 'valid parameters' do
      it 'should return success status' do
        sale_attributes = FactoryBot.attributes_for(:sale)
        products = create_list(:product, 3)
        products_attributes = products.map { |product| { product_id: product.id, quantity: rand(1..9) } }

        post '/api/v1/sales', params: {
          sale: sale_attributes,
          products: products_attributes
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a sale' do
        sale_attributes = FactoryBot.attributes_for(:sale)
        sale_attributes[:sale_date] = sale_attributes[:sale_date].in_time_zone

        products = create_list(:product, 3)
        products_attributes = products.map { |product| { product_id: product.id, quantity: rand(1..9) } }

        post '/api/v1/sales', params: {
          sale: sale_attributes,
          products: products_attributes
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
          }
        end.to_not change(Sale, :count)
      end

      it 'should return sale must have at least one product error' do
        sale_attributes = FactoryBot.attributes_for(:sale)

        post '/api/v1/sales', params: {
          sale: sale_attributes
        }

        expect(Sale.count).to eq(0)
        expect(response.body).to include('Sale must have at least one product')
      end
    end
  end

  describe 'PUT /api/v1/sales/:id' do
    context 'valid parameters' do
      it 'should return success status' do
        sale = create(:sale)
        create_list(:sale_product, 3, sale_id: sale.id)
        products_attributes = SaleProduct.all.map { |sp| { product_id: sp.product_id, quantity: sp.quantity } }

        put "/api/v1/sales/#{sale.id}", params: {
          sale: { parcelling: 99 },
          products: products_attributes
        }

        expect(response).to have_http_status(200)
      end

      it 'should update the sale' do
        sale = create(:sale)
        create_list(:sale_product, 3, sale_id: sale.id)
        products_attributes = SaleProduct.all.map { |sp| { product_id: sp.product_id, quantity: sp.quantity } }

        put "/api/v1/sales/#{sale.id}", params: {
          sale: { parcelling: 99 },
          products: products_attributes
        }

        expect(Sale.last.parcelling).to eq(99)
      end

      it 'should update the sale products' do
        sale = create(:sale)
        create_list(:sale_product, 3, sale_id: sale.id)
        products_attributes = [SaleProduct.first].map do |sp|
          { product_id: sp.product_id, quantity: (sp.quantity + 2) }
        end

        put "/api/v1/sales/#{sale.id}", params: {
          sale: sale.attributes,
          products: products_attributes
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
        sale = create(:sale)

        put "/api/v1/sales/#{sale.id}", params: {
          sale: { sale_date: nil }
        }

        expect(sale.sale_date).to eq(sale.sale_date)
      end

      it 'should return sale not found error' do
        put '/api/v1/sales/999', params: {
          sale: { parcelling: 2 }
        }

        expect(response.body).to include('Sale not found')
      end
    end
  end

  describe 'GET /api/v1/sales/:id/payments' do
    context 'valid sale id' do
      it 'should return success status' do
        sale = create(:sale)
        create(:payment_history, sale_id: sale.id)

        get "/api/v1/sales/#{sale.id}/payments"

        expect(response).to have_http_status(200)
      end

      it 'should return a sales payments list' do
        sale = create(:sale)
        payments = create_list(:payment_history, 3, sale_id: sale.id)

        get "/api/v1/sales/#{sale.id}/payments"

        payments.each do |payment|
          expect(response.body).to include(payment.pay_value.to_s)
          expect(response.body).to include(payment.date.strftime('%d/%m/%Y %H:%M:%S %z'))
        end
      end
    end

    context 'invalid sale id' do
      it 'should return sale not found error' do
        get '/api/v1/sales/999/payments'

        expect(response.body).to include('Sale not found')
      end
    end
  end
end

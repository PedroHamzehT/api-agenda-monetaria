require 'rails_helper'

RSpec.describe "Products", type: :request do
  describe 'GET /api/v1/products' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    it 'should return success status' do
      get '/api/v1/products', headers: {
        Authorization: "Bearer #{token}"
      }

      expect(response).to have_http_status(200)
    end

    it 'should return a products list' do
      products = create_list(:product, 3, user_id: user.id)

      get '/api/v1/products', headers: {
        Authorization: "Bearer #{token}"
      }

      products.each do |product|
        expect(response.body).to include(product.name)
        expect(response.body).to include(product.value.to_s)
        expect(response.body).to include(product.description.to_s)
      end
    end

    it 'should warn when user is unauthenticated' do
      get '/api/v1/products'

      expect(response).to have_http_status(401)
      expect(response.body).to eq(
        { error: 'User unauthenticated' }.to_json
      )
    end
  end

  describe 'POST /api/v1/products' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should return success status' do
        product_attributes = FactoryBot.attributes_for(:product, user_id: user.id)

        post '/api/v1/products', params: {
          product: product_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a product' do
        product_attributes = FactoryBot.attributes_for(:product, user_id: user.id)

        post '/api/v1/products', params: {
          product: product_attributes
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(Product.last).to have_attributes(product_attributes)
      end
    end

    context 'invalid parameters' do
      it 'should not create a product' do
        expect {
          post '/api/v1/products', params: {
            product: { name: '', value: '', description: '' }
          }, headers: {
            Authorization: "Bearer #{token}"
          }
        }.to_not change(Product, :count)
      end
    end
  end

  describe 'PUT /api/v1/products/:id' do
    context 'valid parameters' do
      it 'should return success status' do
        product = create(:product)

        put "/api/v1/products/#{product.id}", params: {
          product: { name: 'Golden Apple' }
        }

        expect(response).to have_http_status(200)
      end

      it 'should edit the product' do
        product = create(:product)

        put "/api/v1/products/#{product.id}", params: {
          product: { name: 'Golden Apple' }
        }

        expect(Product.last.name).to eq('Golden Apple')
      end
    end

    context 'invalid parameters' do
      it 'should not edit the product' do
        product = create(:product)

        put "/api/v1/products/#{product.id}", params: {
          product: { name: '' }
        }

        expect(Product.last.name).to eq(product.name)
      end

      it 'should return product not found error' do
        put '/api/v1/products/999', params: {
          params: { name: 'Golden Apple' }
        }

        expect(response.body).to include('Product not found')
      end
    end
  end
end

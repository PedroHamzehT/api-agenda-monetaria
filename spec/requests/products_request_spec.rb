require 'rails_helper'

RSpec.describe "Products", type: :request do
  describe 'GET /products' do
    it 'should return success status' do
      get '/products'

      expect(response).to have_http_status(200)
    end

    it 'should return a products list' do
      create(:product)
      create(:product)

      get '/products'

      api_result = JSON.parse response.body
      expect(api_result.is_Array?).to eq(true)
      # To finish need to check if api_result product match with db product
    end
  end

  describe 'POST /products' do
    it 'should return success status' do
      product_attributes = FactoryBot.attributes_for(:product)

      post '/products', params: {
        product: product_attributes
      }

      expect(response).to have_http_status(200)
    end

    it 'should create a product' do
      product_attributes = FactoryBot.attributes_for(:product)

      post '/products', params: {
        product: product_attributes
      }

      expect(Product.last).to have_attributes(product_attributes)
    end
  end

  describe 'PUT /products/:id' do
    it 'should return success status' do
      product = create(:product)

      put "/products/#{product.id}", params: {
        product: { name: 'Golden Apple' }
      }

      expect(response).to have_http_status(200)
    end

    it 'should update the product' do
      product = create(:product)

      put "/products/#{product.id}", params: {
        product: { name: 'Golden Apple' }
      }

      expect(Product.last.name).to eq('Golden Apple')
    end
  end
end

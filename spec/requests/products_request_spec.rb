require 'rails_helper'

RSpec.describe "Products", type: :request do
  describe 'GET /products' do
    it 'should return success status' do
      get '/products'

      expect(response).to have_http_status(200)
    end

    it 'should return a products list' do
      products = create_list(:product, 3)

      get '/products'

      products.each do |product|
        expect(response.body).to include(product.name)
        expect(response.body).to include(product.value)
        expect(response.body).to include(product.description)
      end
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

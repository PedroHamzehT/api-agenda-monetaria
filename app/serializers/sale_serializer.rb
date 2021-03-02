class SaleSerializer < ActiveModel::Serializer
  attributes :id,
             :parcelling,
             :tax,
             :total,
             :paid,
             :sale_date,
             :client_id,
             :products,
             :created_at,
             :updated_at

  def sale_date
    object.sale_date.strftime('%d/%m/%Y %H:%M:%S %z')
  end

  def products
    object.sale_products.map do |sale_product|
      {
        product_id: sale_product.product_id,
        product_name: sale_product.product.name,
        quantity: sale_product.quantity
      }
    end
  end
end

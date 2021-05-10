class SaleSerializer < ActiveModel::Serializer
  attributes :id,
             :parcelling,
             :tax,
             :total,
             :paid,
             :sale_date,
             :client_id,
             :products,
             :payments,
             :created_at,
             :updated_at

  def sale_date
    object.sale_date.strftime('%d/%m/%Y')
  end

  def products
    object.sale_products.map do |sale_product|
      {
        id: sale_product.product_id,
        product_name: sale_product.product.name,
        quantity: sale_product.quantity
      }
    end
  end

  def payments
    object.payment_histories.map do |payment|
      {
        id: payment.id,
        pay_value: payment.pay_value,
        date: payment.date.strftime('%d/%m/%Y')
      }
    end
  end

  def total
    '%.2f' % object.total
  end
end

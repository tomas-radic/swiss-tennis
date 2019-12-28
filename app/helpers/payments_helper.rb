module PaymentsHelper
  def payments_table_row_color_class(payment)
    'bg-green' if payment.amount > 0
  end

  def payment_balance_color_classes(payment_balance)
    if payment_balance < 1000
      container_class = 'text-center bg-yellow'
      amount_class = 'font-weight-bold text-danger px-2'
    else
      container_class = 'text-center bg-dark'
      amount_class = 'font-weight-bold px-2'
    end

    [container_class, amount_class]
  end
end

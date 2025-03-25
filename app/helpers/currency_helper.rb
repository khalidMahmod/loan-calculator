# app/helpers/currency_helper.rb
module CurrencyHelper
  def format_myr(amount, options = {})
    return "RM 0.00" if amount.nil? || amount == 0

    # Handle both Money objects and numeric values
    value = amount.is_a?(Money) ? amount.cents / 100.0 : amount.to_f

    # Format with proper Malaysian Ringgit notation
    formatted = "RM #{sprintf("%.2f", value)}"

    # Apply thousands separator
    formatted.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, '\1,')

    formatted
  end

  def to_money(amount)
    Money.from_amount(amount.to_f, "MYR")
  end
end

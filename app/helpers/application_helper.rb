# app/helpers/application_helper.rb
module ApplicationHelper
  # Format currency in Malaysian Ringgit
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

  # Check if a page is active
  def active_page(path)
    current_page?(path) ? "active" : ""
  end

  # Format percentage
  def format_percentage(value, precision = 2)
    return "0.00%" if value.nil?
    "#{sprintf("%.#{precision}f", value)}%"
  end

  # Format currency label based on the field
  def currency_label(field_name)
    "#{field_name.to_s.humanize} (RM)"
  end

  # Format a number as a currency
  def format_currency(amount, currency = "RM")
    number_to_currency(amount, unit: currency, format: "%u %n", delimiter: ",", precision: 2)
  end
end

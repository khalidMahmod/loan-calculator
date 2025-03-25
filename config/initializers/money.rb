# config/initializers/money.rb
require 'money'

# Register Malaysian Ringgit
Money::Currency.register({
  priority:            1,
  iso_code:            "MYR",
  name:                "Malaysian Ringgit",
  symbol:              "RM",
  symbol_first:        true,
  subunit:             "Sen",
  subunit_to_unit:     100,
  thousands_separator: ",",
  decimal_mark:        "."
})

# Configure Money
Money.locale_backend = :i18n
Money.rounding_mode = BigDecimal::ROUND_HALF_UP
Money.default_currency = Money::Currency.new("MYR")

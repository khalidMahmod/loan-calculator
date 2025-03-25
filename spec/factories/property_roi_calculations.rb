FactoryBot.define do
  factory :property_roi_calculation do
    user { nil }
    property_price { "9.99" }
    down_payment { "9.99" }
    loan_amount { "9.99" }
    interest_rate { "9.99" }
    loan_term { 1 }
    monthly_rental { "9.99" }
    occupancy_rate { "9.99" }
    other_income { "9.99" }
    property_tax { "9.99" }
    insurance { "9.99" }
    maintenance { "9.99" }
    management_fees { "9.99" }
    utilities { "9.99" }
    vacancy_rate { "9.99" }
    holding_period { 1 }
    appreciation_rate { "9.99" }
    rental_growth_rate { "9.99" }
    cap_rate { "9.99" }
    cash_on_cash_return { "9.99" }
    total_roi { "9.99" }
    break_even_ratio { "9.99" }
    payback_period { "9.99" }
    debt_coverage_ratio { "9.99" }
    currency { "MyString" }
  end
end

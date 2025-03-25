# app/models/property_roi_calculator.rb
class PropertyRoiCalculator
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Property attributes
  attribute :property_price, :float, default: 500000
  attribute :closing_costs, :float, default: 15000
  attribute :down_payment, :float, default: 100000
  attribute :interest_rate, :float, default: 4.5
  attribute :loan_term, :integer, default: 30
  attribute :renovation_costs, :float, default: 25000
  attribute :appreciation_rate, :float, default: 3.0
  attribute :holding_period, :integer, default: 10
  attribute :currency_type, :string, default: 'MYR'

  # Income attributes
  attribute :monthly_rental, :float, default: 2500
  attribute :other_income, :float, default: 200
  attribute :occupancy_rate, :float, default: 95
  attribute :rental_growth_rate, :float, default: 2.0

  # Expense attributes
  attribute :property_tax, :float, default: 2000
  attribute :insurance, :float, default: 1200
  attribute :maintenance, :float, default: 2400
  attribute :management_fees, :float, default: 3000
  attribute :utilities, :float, default: 1200
  attribute :other_expenses, :float, default: 1000  # Added this attribute
  attribute :vacancy_rate, :float, default: 5.0

  validates :property_price, :down_payment, :interest_rate, :loan_term, :holding_period,
            :monthly_rental, :occupancy_rate, presence: true, numericality: { greater_than: 0 }

  validates :vacancy_rate, :occupancy_rate, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  validates :down_payment, numericality: {
    less_than_or_equal_to: ->(calculator) { calculator.property_price }
  }

  def loan_amount
    property_price - down_payment
  end

  def calculate_mortgage_payment
    monthly_rate = interest_rate / 100 / 12
    total_months = loan_term * 12

    if loan_amount <= 0 || monthly_rate <= 0 || total_months <= 0
      return 0
    end

    x = (1 + monthly_rate) ** total_months
    (loan_amount * x * monthly_rate) / (x - 1)
  end

  def calculate
    # Calculate initial investment
    initial_investment = down_payment + closing_costs.to_f + renovation_costs.to_f

    # Calculate annual income
    potential_annual_rental = monthly_rental * 12
    actual_annual_rental = potential_annual_rental * (occupancy_rate / 100)
    annual_other_income = other_income.to_f * 12
    total_annual_income = actual_annual_rental + annual_other_income

    # Calculate annual expenses
    monthly_mortgage = calculate_mortgage_payment
    annual_mortgage = monthly_mortgage * 12
    vacancy_loss = potential_annual_rental * (vacancy_rate / 100)
    annual_operating_expenses =
      property_tax.to_f +
      insurance.to_f +
      maintenance.to_f +
      management_fees.to_f +
      utilities.to_f +
      other_expenses.to_f +
      vacancy_loss

    # Calculate NOI (Net Operating Income)
    noi = total_annual_income - annual_operating_expenses

    # Calculate annual cashflow
    annual_cash_flow = noi - annual_mortgage
    monthly_cash_flow = annual_cash_flow / 12

    # Calculate ROI metrics
    cash_on_cash_return = (annual_cash_flow / initial_investment) * 100
    cap_rate = (noi / property_price) * 100
    gross_rental_yield = (potential_annual_rental / property_price) * 100
    break_even_ratio = ((annual_operating_expenses + annual_mortgage) / potential_annual_rental) * 100
    debt_coverage_ratio = noi / annual_mortgage if annual_mortgage > 0

    # Calculate payback period (in years)
    payback_period = initial_investment / annual_cash_flow if annual_cash_flow > 0

    # Generate amortization schedule
    amortization_schedule = generate_amortization_schedule

    # Generate yearly data for projection charts
    yearly_projections = []
    cumulative_cash_flow = 0
    property_value = property_price
    cumulative_equity = down_payment
    remaining_loan_balance = loan_amount
    rental_income = actual_annual_rental
    expenses = annual_operating_expenses

    for year in 1..holding_period
      # Property appreciates each year
      property_value *= (1 + appreciation_rate.to_f / 100)

      # Rental income increases each year
      rental_income *= (1 + rental_growth_rate.to_f / 100)

      # Expenses might increase as well (assuming 2% inflation)
      expenses *= 1.02

      # Calculate loan principal paid this year (simplified calculation)
      annual_interest = remaining_loan_balance * (interest_rate / 100)
      annual_principal = annual_mortgage - annual_interest
      remaining_loan_balance -= annual_principal
      remaining_loan_balance = 0 if remaining_loan_balance < 0

      # Equity increases with principal payments and appreciation
      cumulative_equity = property_value - remaining_loan_balance

      # Annual cashflow might increase with rental increases
      yearly_noi = rental_income + annual_other_income - expenses
      yearly_annual_cash_flow = yearly_noi - annual_mortgage
      cumulative_cash_flow += yearly_annual_cash_flow

      yearly_projections << {
        year: year,
        property_value: property_value,
        loan_balance: remaining_loan_balance,
        equity: cumulative_equity,
        rental_income: rental_income,
        expenses: expenses,
        cash_flow: yearly_annual_cash_flow,
        cumulative_cash_flow: cumulative_cash_flow
      }
    end

    # Calculate total profit
    final_property_value = property_value
    total_equity_gain = cumulative_equity - down_payment
    total_cash_flow = cumulative_cash_flow
    total_profit = total_equity_gain + total_cash_flow

    # Calculate total ROI
    total_roi = (total_profit / initial_investment) * 100

    # Calculate total interest paid
    total_interest = annual_mortgage * loan_term * 12 - loan_amount

    # Return results
    {
      monthly_payment: monthly_mortgage,
      annual_mortgage: annual_mortgage,
      initial_investment: initial_investment,
      net_operating_income: noi,
      monthly_cash_flow: monthly_cash_flow,
      annual_cash_flow: annual_cash_flow,
      cash_on_cash_return: cash_on_cash_return,
      cap_rate: cap_rate,
      gross_rental_yield: gross_rental_yield,
      break_even_ratio: break_even_ratio,
      debt_coverage_ratio: debt_coverage_ratio || 0,
      payback_period: payback_period || 0,
      total_roi: total_roi,
      total_profit: total_profit,
      final_property_value: final_property_value,
      total_interest: total_interest,
      amortization_schedule: amortization_schedule,
      yearly_projections: yearly_projections
    }
  end

  def currency_symbol
    case currency_type.to_s.upcase
    when 'MYR'
      'RM'
    when 'USD'
      '$'
    when 'SGD'
      'S$'
    when 'GBP'
      '£'
    when 'EUR'
      '€'
    else
      'RM'
    end
  end

  def down_payment_percentage
    property_price > 0 ? down_payment / property_price : 0
  end

  def annual_property_tax
    property_tax
  end

  def annual_insurance
    insurance
  end

  def annual_maintenance
    maintenance
  end

  def annual_management_fees
    management_fees
  end

  def annual_utilities
    utilities
  end

  def annual_other_expenses
    other_expenses
  end

  private

  def generate_amortization_schedule
    schedule = []
    remaining_balance = loan_amount
    monthly_payment = calculate_mortgage_payment
    monthly_rate = interest_rate / 100 / 12

    (1..(loan_term * 12)).each do |payment_number|
      # Calculate interest portion of payment
      interest_payment = remaining_balance * monthly_rate

      # Calculate principal portion of payment
      principal_payment = monthly_payment - interest_payment

      # Update remaining balance
      remaining_balance -= principal_payment
      remaining_balance = 0 if remaining_balance < 0

      # Add to schedule
      schedule << {
        payment_number: payment_number,
        payment_amount: monthly_payment,
        interest_payment: interest_payment,
        principal_payment: principal_payment,
        remaining_balance: remaining_balance
      }
    end

    schedule
  end
end

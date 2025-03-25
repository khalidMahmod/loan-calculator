# app/services/property_roi_calculator.rb
class PropertyRoiCalculator
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Define attributes (same fields as before, but without persistence)
  attribute :property_price, :decimal
  attribute :down_payment, :decimal
  attribute :loan_amount, :decimal
  attribute :interest_rate, :decimal
  attribute :loan_term, :integer
  attribute :monthly_rental, :decimal
  attribute :occupancy_rate, :decimal
  attribute :other_income, :decimal, default: 0
  attribute :property_tax, :decimal, default: 0
  attribute :insurance, :decimal, default: 0
  attribute :maintenance, :decimal, default: 0
  attribute :management_fees, :decimal, default: 0
  attribute :utilities, :decimal, default: 0
  attribute :vacancy_rate, :decimal, default: 0
  attribute :holding_period, :integer
  attribute :appreciation_rate, :decimal, default: 0
  attribute :rental_growth_rate, :decimal, default: 0

  # Validations
  validates :property_price, :down_payment, :interest_rate, :loan_term,
            :monthly_rental, :occupancy_rate, :holding_period, presence: true
  validates :property_price, :down_payment, :monthly_rental, numericality: { greater_than: 0 }
  validates :interest_rate, :occupancy_rate, :vacancy_rate,
            :appreciation_rate, :rental_growth_rate,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :loan_term, :holding_period, numericality: { only_integer: true, greater_than: 0 }

  # Main calculation method that returns all metrics as a hash
  def calculate
    # Calculate loan amount if not provided
    self.loan_amount ||= property_price - down_payment

    # Calculate all metrics
    {
      monthly_payment: calculate_monthly_payment,
      yearly_projections: yearly_projections,
      cap_rate: calculate_cap_rate,
      cash_on_cash_return: calculate_cash_on_cash_return,
      total_roi: calculate_total_roi,
      break_even_ratio: calculate_break_even_ratio,
      debt_coverage_ratio: calculate_debt_coverage_ratio,
      payback_period: calculate_payback_period
    }
  end

  # Calculate monthly mortgage payment
  def calculate_monthly_payment
    monthly_interest_rate = interest_rate / 100.0 / 12
    num_payments = loan_term * 12

    if monthly_interest_rate.zero?
      loan_amount / num_payments
    else
      loan_amount * monthly_interest_rate * (1 + monthly_interest_rate) ** num_payments /
        ((1 + monthly_interest_rate) ** num_payments - 1)
    end
  end

  # Returns yearly cash flow projections
  def yearly_projections
    projections = []

    current_property_value = property_price
    current_loan_balance = loan_amount
    yearly_appreciation = appreciation_rate / 100.0
    yearly_rental_growth = rental_growth_rate / 100.0

    monthly_payment = calculate_monthly_payment

    (1..holding_period).each do |year|
      # Update property value with appreciation
      current_property_value = current_property_value * (1 + yearly_appreciation)

      # Update rental income with growth
      current_monthly_rental = monthly_rental * (1 + yearly_rental_growth) ** (year - 1)

      # Calculate annual rental income accounting for occupancy
      annual_rental_income = current_monthly_rental * 12 * (occupancy_rate / 100.0)

      # Calculate annual expenses
      annual_mortgage_payment = monthly_payment * 12
      annual_expenses = calculate_annual_expenses(year)

      # Calculate cash flow
      annual_cash_flow = annual_rental_income + (other_income * 12) - annual_expenses - annual_mortgage_payment

      # Update loan balance (simplified - should use amortization schedule in real app)
      monthly_interest_rate = interest_rate / 100.0 / 12
      interest_payment = current_loan_balance * monthly_interest_rate * 12
      principal_payment = annual_mortgage_payment - interest_payment
      current_loan_balance -= principal_payment
      current_loan_balance = [current_loan_balance, 0].max

      # Calculate equity
      equity = current_property_value - current_loan_balance

      projections << {
        year: year,
        property_value: current_property_value,
        loan_balance: current_loan_balance,
        equity: equity,
        rental_income: annual_rental_income,
        expenses: annual_expenses,
        cash_flow: annual_cash_flow
      }
    end

    projections
  end

  # Calculate annual expenses
  def calculate_annual_expenses(year)
    # Base annual expenses
    annual_property_tax = property_tax * 12
    annual_insurance = insurance * 12
    annual_maintenance = maintenance * 12
    annual_management = management_fees * 12
    annual_utilities = utilities * 12

    # Vacancy cost based on potential rental income
    current_monthly_rental = monthly_rental * (1 + (rental_growth_rate / 100.0)) ** (year - 1)
    annual_potential_rent = current_monthly_rental * 12
    vacancy_cost = annual_potential_rent * (vacancy_rate / 100.0)

    annual_property_tax + annual_insurance + annual_maintenance +
      annual_management + annual_utilities + vacancy_cost
  end

  # Calculate cap rate (NOI / Property Value)
  def calculate_cap_rate
    annual_rental_income = monthly_rental * 12 * (occupancy_rate / 100.0)
    annual_expenses = calculate_annual_expenses(1)
    noi = annual_rental_income - annual_expenses

    (noi / property_price) * 100
  end

  # Calculate cash-on-cash return (Annual Cash Flow / Initial Investment)
  def calculate_cash_on_cash_return
    annual_rental_income = monthly_rental * 12 * (occupancy_rate / 100.0)
    annual_expenses = calculate_annual_expenses(1)
    annual_mortgage_payment = calculate_monthly_payment * 12
    annual_cash_flow = annual_rental_income - annual_expenses - annual_mortgage_payment

    initial_investment = down_payment

    (annual_cash_flow / initial_investment) * 100
  end

  # Calculate total ROI over holding period
  def calculate_total_roi
    projections = yearly_projections
    final_year = projections.last

    total_cash_flow = projections.sum { |p| p[:cash_flow] }
    equity_gain = final_year[:equity] - down_payment
    total_return = total_cash_flow + equity_gain

    (total_return / down_payment) * 100
  end

  # Calculate break-even ratio
  def calculate_break_even_ratio
    annual_operating_expenses = calculate_annual_expenses(1)
    annual_debt_service = calculate_monthly_payment * 12
    annual_potential_rental_income = monthly_rental * 12

    ((annual_operating_expenses + annual_debt_service) / annual_potential_rental_income) * 100
  end

  # Calculate debt coverage ratio
  def calculate_debt_coverage_ratio
    annual_rental_income = monthly_rental * 12 * (occupancy_rate / 100.0)
    annual_expenses = calculate_annual_expenses(1)
    noi = annual_rental_income - annual_expenses
    annual_debt_service = calculate_monthly_payment * 12

    noi / annual_debt_service
  end

  # Calculate payback period (simplified)
  def calculate_payback_period
    projections = yearly_projections
    cumulative_cash_flow = 0

    projections.each_with_index do |p, index|
      cumulative_cash_flow += p[:cash_flow]
      return index + 1 if cumulative_cash_flow >= down_payment
    end

    # If investment doesn't pay back within holding period
    return holding_period + 1
  end
end

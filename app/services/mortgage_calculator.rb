# app/services/mortgage_calculator.rb
class MortgageCalculator
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Define attributes
  attribute :loan_amount, :decimal
  attribute :interest_rate, :decimal
  attribute :loan_term, :integer
  attribute :down_payment, :decimal, default: 0
  attribute :bank_type, :string, default: 'conventional'

  # Validations
  validates :loan_amount, :interest_rate, :loan_term, presence: true
  validates :loan_amount, :down_payment, numericality: { greater_than_or_equal_to: 0 }
  validates :interest_rate, numericality: { greater_than: 0, less_than_or_equal_to: 30 }
  validates :loan_term, numericality: { only_integer: true, greater_than: 0 }
  validates :bank_type, inclusion: { in: ['conventional', 'islamic'] }

  # Main calculation method
  def calculate
    monthly_payment = calculate_monthly_payment
    total_payment = monthly_payment * loan_term * 12
    total_interest = total_payment - loan_amount

    {
      monthly_payment: monthly_payment,
      total_payment: total_payment,
      total_interest: total_interest,
      amortization_schedule: amortization_schedule,
      stamp_duty: calculate_stamp_duty,
      legal_fees: calculate_legal_fees,
      mrta_premium: calculate_mrta_premium
    }
  end

  # Calculate monthly payment
  def calculate_monthly_payment
    # Adjust calculation based on bank type
    if bank_type == 'islamic'
      calculate_islamic_monthly_payment
    else
      calculate_conventional_monthly_payment
    end
  end

  # Calculate conventional monthly payment
  def calculate_conventional_monthly_payment
    monthly_interest_rate = interest_rate / 100.0 / 12
    num_payments = loan_term * 12

    if monthly_interest_rate.zero?
      loan_amount / num_payments
    else
      loan_amount * monthly_interest_rate * (1 + monthly_interest_rate) ** num_payments /
        ((1 + monthly_interest_rate) ** num_payments - 1)
    end
  end

  # Calculate Islamic monthly payment (simplified)
  def calculate_islamic_monthly_payment
    # For Islamic banking, we're simplifying to use a similar formula
    # but in reality would be calculated differently based on the Islamic product
    profit_rate = interest_rate / 100.0
    total_profit = loan_amount * profit_rate * loan_term
    total_payable = loan_amount + total_profit
    total_payable / (loan_term * 12)
  end

  # Generate amortization schedule
  def amortization_schedule
    if bank_type == 'islamic'
      # Islamic financing typically has a fixed payment structure
      generate_islamic_schedule
    else
      generate_conventional_schedule
    end
  end

  # Generate conventional amortization schedule
  def generate_conventional_schedule
    schedule = []

    monthly_interest_rate = interest_rate / 100.0 / 12
    monthly_payment = calculate_monthly_payment
    remaining_balance = loan_amount

    (1..(loan_term * 12)).each do |payment_number|
      interest_payment = remaining_balance * monthly_interest_rate
      principal_payment = monthly_payment - interest_payment
      remaining_balance -= principal_payment

      # Ensure we don't have negative balance due to rounding
      remaining_balance = [remaining_balance, 0].max

      schedule << {
        payment_number: payment_number,
        payment_amount: monthly_payment,
        principal_payment: principal_payment,
        interest_payment: interest_payment,
        remaining_balance: remaining_balance
      }
    end

    schedule
  end

  # Generate Islamic payment schedule (simplified)
  def generate_islamic_schedule
    schedule = []

    # For Islamic financing, let's assume equal principal + profit payments
    # This is simplified; actual Islamic products use different structures
    monthly_payment = calculate_monthly_payment
    total_payment = monthly_payment * loan_term * 12
    total_profit = total_payment - loan_amount

    principal_per_month = loan_amount / (loan_term * 12)
    profit_per_month = total_profit / (loan_term * 12)
    remaining_balance = loan_amount

    (1..(loan_term * 12)).each do |payment_number|
      remaining_balance -= principal_per_month

      # Ensure we don't have negative balance due to rounding
      remaining_balance = [remaining_balance, 0].max

      schedule << {
        payment_number: payment_number,
        payment_amount: monthly_payment,
        principal_payment: principal_per_month,
        profit_payment: profit_per_month,
        remaining_balance: remaining_balance
      }
    end

    schedule
  end

  # Calculate stamp duty based on Malaysian rates
  def calculate_stamp_duty
    # Malaysian stamp duty rates for loan agreements
    # RM1.00 for every RM1,000 or part thereof
    (loan_amount / 1000.0).ceil
  end

  # Calculate legal fees based on Malaysian standard scale
  def calculate_legal_fees
    # Standard legal fee scale for Malaysian property loans
    case loan_amount
    when 0..500000
      loan_amount * 0.01
    when 500001..1000000
      5000 + (loan_amount - 500000) * 0.008
    when 1000001..3000000
      9000 + (loan_amount - 1000000) * 0.005
    else
      19000 + (loan_amount - 3000000) * 0.0025
    end
  end

  # Calculate MRTA premium (simplified)
  def calculate_mrta_premium
    # Simplified calculation - in reality based on age, term, etc.
    loan_amount * 0.03
  end
end

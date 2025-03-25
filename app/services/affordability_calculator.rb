# app/services/affordability_calculator.rb
class AffordabilityCalculator
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Constants for Malaysian debt-to-income standards
  DSR_MAX = 0.7  # 70% maximum debt service ratio

  # Define attributes
  attribute :primary_income, :decimal
  attribute :additional_income, :decimal, default: 0
  attribute :co_applicant_income, :decimal, default: 0
  attribute :monthly_debt, :decimal, default: 0
  attribute :down_payment_amount, :decimal, default: 0
  attribute :interest_rate, :decimal
  attribute :loan_term, :integer
  attribute :bank_type, :string, default: 'conventional'

  # Validations
  validates :primary_income, :interest_rate, :loan_term, presence: true
  validates :primary_income, :additional_income, :co_applicant_income,
            :down_payment_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :monthly_debt, numericality: { greater_than_or_equal_to: 0 }
  validates :interest_rate, numericality: { greater_than: 0, less_than_or_equal_to: 30 }
  validates :loan_term, numericality: { only_integer: true, greater_than: 0 }

  # Main calculation method
  def calculate
    # Calculate total monthly income
    total_monthly_income = primary_income + additional_income + co_applicant_income

    # Calculate maximum allowable monthly payment based on debt-to-income ratio
    available_monthly_payment = (total_monthly_income * DSR_MAX) - monthly_debt

    # Convert interest rate to monthly value
    monthly_interest_rate = interest_rate / 100.0 / 12

    # Calculate maximum loan amount using the mortgage payment formula
    num_payments = loan_term * 12

    if monthly_interest_rate.zero?
      max_loan = available_monthly_payment * num_payments
    else
      max_loan = available_monthly_payment *
        ((1 - (1 + monthly_interest_rate) ** -num_payments) / monthly_interest_rate)
    end

    # Calculate max property price by adding down payment
    max_property = max_loan + down_payment_amount

    # Calculate ratios
    total_debt_payment = monthly_debt + available_monthly_payment
    debt_to_income_ratio = (total_debt_payment / total_monthly_income) * 100

    # Loan to value ratio
    loan_to_value_ratio = max_property > 0 ? (max_loan / max_property) * 100 : 0

    # Return all calculated values
    {
      max_loan_amount: max_loan,
      max_property_price: max_property,
      monthly_payment: available_monthly_payment,
      debt_to_income_ratio: debt_to_income_ratio,
      loan_to_value_ratio: loan_to_value_ratio,
      monthly_payment_breakdown: monthly_payment_breakdown(max_property, available_monthly_payment),
      mrta_premium: calculate_mrta_premium(max_loan)
    }
  end

  # Get monthly payment breakdown
  def monthly_payment_breakdown(max_property_price, monthly_payment)
    # Assumes a typical breakdown for Malaysian properties
    property_tax_monthly = max_property_price * 0.002 / 12  # Rough estimate
    insurance_monthly = max_property_price * 0.003 / 12     # Rough estimate
    maintenance_monthly = max_property_price * 0.005 / 12   # Rough estimate

    {
      mortgage_payment: monthly_payment - property_tax_monthly - insurance_monthly - maintenance_monthly,
      property_tax: property_tax_monthly,
      insurance: insurance_monthly,
      maintenance: maintenance_monthly
    }
  end

  # Calculate MRTA (Mortgage Reducing Term Assurance) premium
  def calculate_mrta_premium(max_loan_amount)
    # Simplified calculation - in reality this would depend on age, loan term, etc.
    max_loan_amount * 0.03  # 3% of loan amount as a simple approximation
  end
end

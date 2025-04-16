
class LoanCalculationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def eligibility
    calculator = LoanCalculator.new(loan_params)

    if calculator.valid?
      render json: calculator.calculate(calculation_type), status: :ok
    else
      render json: { errors: calculator.errors }, status: :unprocessable_entity
    end
  end

  def mortgage
    calculator = LoanCalculator.new(mortgage_params)

    if calculator.valid_for_mortgage?
      render json: calculator.calculate_mortgage, status: :ok
    else
      render json: { errors: calculator.errors }, status: :unprocessable_entity
    end
  end

  def rental_yield
    calculator = LoanCalculator.new(rental_yield_params)

    if calculator.valid_for_rental_yield?
      render json: calculator.calculate_rental_yield, status: :ok
    else
      render json: { errors: calculator.errors }, status: :unprocessable_entity
    end
  end

  def down_payment_plan
    calculator = LoanCalculator.new(down_payment_params)

    if calculator.valid_for_down_payment_plan?
      render json: calculator.calculate_down_payment_plan, status: :ok
    else
      render json: { errors: calculator.errors }, status: :unprocessable_entity
    end
  end

  private

  def calculation_type
    params[:calculation_type] || 'eligibility'
  end

  def loan_params
    params.permit(
      :monthly_net_income,
      :outstanding_credit_card_balance,
      :existing_monthly_loan_repayment,
      :loan_amount,
      :down_payment,
      :loan_tenure_years,
      :interest_rate,
      :calculation_type
    )
  end

  def mortgage_params
    params.permit(
      :loan_amount,
      :interest_rate,
      :loan_tenure_years
    )
  end

  def rental_yield_params
    params.permit(
      :property_price,
      :down_payment,
      :loan_tenure_years,
      :interest_rate,
      :monthly_rent,
      :expected_vacancy_rate,
      :local_authority_tax,
      :insurance,
      :repairs_and_maintenance,
      :other_expenses
    )
  end

  def down_payment_params
    params.permit(
      :property_price,
      :down_payment_percentage,
      :current_savings,
      :monthly_savings,
      :interest_rate,
      :annual_property_price_inflation
    )
  end
end

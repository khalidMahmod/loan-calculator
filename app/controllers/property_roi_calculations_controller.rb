# app/controllers/property_roi_calculations_controller.rb
class PropertyRoiCalculationsController < ApplicationController
  def new
    @calculator = PropertyRoiCalculator.new
  end

  def calculate
    @calculator = PropertyRoiCalculator.new(calculator_params)

    if @calculator.valid?
      @results = @calculator.calculate

      render :results
    else
      flash.now[:alert] = "Please correct the errors below."
      render :new
    end
  end

  # app/controllers/property_roi_calculations_controller.rb
  # Update your export_pdf method

  def export_pdf
    calculator_attrs = {}

    if params[:property_roi_calculator].present?
      calculator_attrs = params[:property_roi_calculator].permit(
        :property_price, :down_payment, :interest_rate, :loan_term, :holding_period,
        :monthly_rental, :occupancy_rate, :other_income,
        :property_tax, :insurance, :maintenance, :management_fees, :utilities, :other_expenses, :vacancy_rate,
        :appreciation_rate, :rental_growth_rate, :closing_costs, :renovation_costs, :currency_type
      )
    end

    @calculator = PropertyRoiCalculator.new(calculator_attrs)
    @results = @calculator.calculate

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "property_roi_analysis_report",
              template: "property_roi_calculations/pdf_report", 
              layout: "layouts/pdf",
              formats: [:html],
              encoding: 'UTF-8',
              disposition: 'attachment'
      end
    end
  end

  def export_excel
    # Get parameters from the query string instead of the POST body
    calculator_attrs = if params[:property_roi_calculator].present?
                         params[:property_roi_calculator].permit(
                           :property_price, :down_payment, :interest_rate, :loan_term, :holding_period,
                           :monthly_rental, :occupancy_rate, :other_income,
                           :property_tax, :insurance, :maintenance, :management_fees, :utilities, :other_expenses, :vacancy_rate,
                           :appreciation_rate, :rental_growth_rate, :closing_costs, :renovation_costs, :currency_type
                         )
                       else
                         {}
                       end

    @calculator = PropertyRoiCalculator.new(calculator_attrs)
    @results = @calculator.calculate

    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  private

  def calculator_params
    params.require(:calculator).permit(
      :property_price, :down_payment, :interest_rate, :loan_term, :holding_period,
      :monthly_rental, :occupancy_rate, :other_income,
      :property_tax, :insurance, :maintenance, :management_fees, :utilities, :other_expenses, :vacancy_rate,
      :appreciation_rate, :rental_growth_rate, :closing_costs, :renovation_costs, :currency_type
    )
  end
end

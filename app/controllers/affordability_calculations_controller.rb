# app/controllers/affordability_calculations_controller.rb
class AffordabilityCalculationsController < ApplicationController
  # GET /affordability
  def new
    @calculator = AffordabilityCalculator.new
  end

  # POST /affordability/calculate
  def calculate
    @calculator = AffordabilityCalculator.new(calculator_params)

    if @calculator.valid?
      # Debug: Print available attributes to the console
      puts "DEBUG: AffordabilityCalculator attributes: #{@calculator.attributes.keys}"
      puts "DEBUG: AffordabilityCalculator instance variables: #{@calculator.instance_variables}"

      @results = @calculator.calculate
      render :results
    else
      render :new
    end
  end

  # POST /affordability/export-pdf
  def export_pdf
    @calculator = AffordabilityCalculator.new(calculator_params)
    @results = @calculator.calculate

    respond_to do |format|
      format.pdf do
        render pdf: "affordability_report",
               template: "affordability_calculations/pdf_report",
               layout: "pdf",
               page_size: "A4",
               orientation: "Portrait",
               lowquality: true,
               zoom: 1,
               dpi: 75
      end
    end
  end

  # POST /affordability/export-excel
  def export_excel
    @calculator = AffordabilityCalculator.new(calculator_params)
    @results = @calculator.calculate

    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="affordability_report.xlsx"'
      end
    end
  end

  private

  def calculator_params
    params.require(:affordability_calculator).permit(
      :primary_income,
      :additional_income,
      :co_applicant_income,
      :monthly_debt,
      :down_payment_amount,
      :interest_rate,
      :loan_term
    )
  end
end

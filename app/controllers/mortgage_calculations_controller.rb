# app/controllers/mortgage_calculations_controller.rb
class MortgageCalculationsController < ApplicationController
  # GET /mortgage
  def new
    @calculator = MortgageCalculator.new
  end

  # POST /mortgage/calculate
  def calculate
    @calculator = MortgageCalculator.new(calculator_params)

    if @calculator.valid?
      @results = @calculator.calculate

      # Prepare data for JavaScript to avoid complex ERB in JS
      @chart_data = {
        loan_amount: @calculator.loan_amount,
        total_interest: @results[:total_interest],
        payment_type: @calculator.bank_type == 'islamic' ? 'Profit' : 'Interest',
        amortization: @results[:amortization_schedule].first(120).as_json
      }

      render :results
    else
      render :new
    end
  end

  # POST /mortgage/export-pdf
  def export_pdf
    @calculator = MortgageCalculator.new(calculator_params)
    @results = @calculator.calculate

    respond_to do |format|
      format.pdf do
        render pdf: "mortgage_report",
               template: "mortgage_calculations/pdf_report",
               layout: "pdf",
               page_size: "A4",
               orientation: "Portrait",
               lowquality: true,
               zoom: 1,
               dpi: 75
      end
    end
  end

  # POST /mortgage/export-excel
  def export_excel
    @calculator = MortgageCalculator.new(calculator_params)
    @results = @calculator.calculate

    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="mortgage_report.xlsx"'
      end
    end
  end

  # POST /mortgage/amortization-schedule
  def amortization_schedule
    @calculator = MortgageCalculator.new(calculator_params)
    @schedule = @calculator.amortization_schedule

    respond_to do |format|
      format.json { render json: @schedule }
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="amortization_schedule.xlsx"'
      end
    end
  end

  private

  def calculator_params
    params.require(:mortgage_calculator).permit(
      :loan_amount,
      :interest_rate,
      :loan_term,
      :down_payment,
      :bank_type
    )
  end
end

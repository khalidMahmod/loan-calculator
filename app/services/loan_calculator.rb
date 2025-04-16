class LoanCalculator
  attr_reader :errors

  def initialize(params)
    @monthly_net_income = params[:monthly_net_income].to_f
    @outstanding_credit_card_balance = params[:outstanding_credit_card_balance].to_f
    @existing_monthly_loan_repayment = params[:existing_monthly_loan_repayment].to_f
    @loan_amount = params[:loan_amount].to_f
    @property_price = params[:property_price].to_f
    @down_payment = params[:down_payment].to_f
    @down_payment_percentage = params[:down_payment_percentage].to_f
    @loan_tenure_years = params[:loan_tenure_years].to_i
    @interest_rate = params[:interest_rate].to_f
    @monthly_rent = params[:monthly_rent].to_f
    @expected_vacancy_rate = params[:expected_vacancy_rate].to_f
    @local_authority_tax = params[:local_authority_tax].to_f
    @insurance = params[:insurance].to_f
    @repairs_and_maintenance = params[:repairs_and_maintenance].to_f
    @other_expenses = params[:other_expenses].to_f
    @current_savings = params[:current_savings].to_f
    @monthly_savings = params[:monthly_savings].to_f
    @annual_property_price_inflation = params[:annual_property_price_inflation].to_f
    @errors = {}
  end

  def valid?
    @errors = {}
    validate_eligibility_params
    @errors.empty?
  end

  def valid_for_mortgage?
    @errors = {}
    validate_mortgage_params
    @errors.empty?
  end

  def valid_for_rental_yield?
    @errors = {}
    validate_rental_yield_params
    @errors.empty?
  end

  def valid_for_down_payment_plan?
    @errors = {}
    validate_down_payment_plan_params
    @errors.empty?
  end

  # Calculate mortgage repayment (simpler calculation)
  def calculate_mortgage
    monthly_payment = calculate_monthly_payment(@loan_amount)

    # Calculate first month's interest and principal
    first_month_interest = @loan_amount * (@interest_rate / (12 * 100))
    first_month_principal = monthly_payment - first_month_interest

    # Calculate percentages for the first month's breakdown chart
    principal_percentage = (first_month_principal / monthly_payment * 100).round(0)
    interest_percentage = (first_month_interest / monthly_payment * 100).round(0)

    {
      estimated_monthly_repayment: monthly_payment.round(0),
      monthly_payment: {
        amount: monthly_payment.round(0),
        principal: first_month_principal.round(0),
        interest: first_month_interest.round(0),
        principal_percentage: principal_percentage,
        interest_percentage: interest_percentage
      }
    }
  end

  # Calculate rental yield
  def calculate_rental_yield
    # Calculate loan amount if not provided directly
    loan_amount = @loan_amount > 0 ? @loan_amount : (@property_price - @down_payment)

    # Calculate monthly mortgage payment
    monthly_mortgage = calculate_monthly_payment(loan_amount)

    # Calculate annual rental income with vacancy adjustment
    annual_rent = @monthly_rent * 12
    effective_annual_rent = annual_rent * (1 - (@expected_vacancy_rate / 100))

    # Calculate property expenses
    annual_expenses = calculate_annual_expenses
    monthly_expenses = annual_expenses / 12

    # Calculate rental yields
    gross_annual_rental_yield = (annual_rent / @property_price) * 100
    net_annual_rental_yield = ((effective_annual_rent - annual_expenses) / @property_price) * 100

    # Calculate monthly cash flow
    monthly_cash_flow = @monthly_rent - monthly_mortgage - monthly_expenses
    annual_cash_flow = monthly_cash_flow * 12

    {
      gross_annual_rental_yield: gross_annual_rental_yield.round(2),
      net_annual_rental_yield: net_annual_rental_yield.round(2),
      monthly_cash_flow: monthly_cash_flow.round(0),
      estimated_annual_income: annual_cash_flow.round(0),
      monthly_breakdown: {
        rental_income: @monthly_rent.round(0),
        mortgage_payment: monthly_mortgage.round(0),
        property_expenses: monthly_expenses.round(0),
        cash_flow: monthly_cash_flow.round(0)
      }
    }
  end

  # Calculate down payment savings plan
  def calculate_down_payment_plan
    # Calculate target down payment amount
    down_payment_amount = (@property_price * @down_payment_percentage) / 100

    # Calculate current percentage saved
    current_percentage = (@current_savings / down_payment_amount) * 100

    # Calculate months needed to reach target with monthly savings and interest
    months_needed = calculate_months_to_save(down_payment_amount)

    # Format the ready date
    ready_date = format_ready_date(months_needed)

    # Format years and months
    years_months = format_years_months(months_needed)

    # Calculate savings rate comparison
    savings_comparison = calculate_savings_rate_comparison(down_payment_amount)

    {
      down_payment_timeline: {
        starting_with: @current_savings.round(0),
        monthly_savings: @monthly_savings.round(0),
        ready_in: years_months,
        ready_date: ready_date
      },
      need_to_save: down_payment_amount.round(0),
      savings_rate_comparison: savings_comparison
    }
  end


  # Main calculation method that can handle different types of calculations
  def calculate(type = 'eligibility')
    case type
    when 'mortgage'
      calculate_mortgage
    when 'rental_yield'
      calculate_rental_yield
    when 'down_payment_plan'
      calculate_down_payment_plan
    when 'eligibility', ''
      calculate_eligibility
    else
      { error: 'Invalid calculation type' }
    end
  end

  # Calculate home loan eligibility (more complex calculation)
  def calculate_eligibility
    # Calculate the actual loan amount after down payment
    actual_loan_amount = @loan_amount - @down_payment

    # Calculate maximum loan amount based on income (typically 28-36% of monthly income)
    # Using 36% of income for total debt payments (DTI ratio)
    total_debt_capacity = @monthly_net_income * 0.36
    available_for_mortgage = total_debt_capacity - (@outstanding_credit_card_balance * 0.03) - @existing_monthly_loan_repayment

    # Calculate maximum loan amount based on available mortgage payment capacity
    max_loan_amount = calculate_max_loan_from_payment(available_for_mortgage)

    # Calculate monthly payment for requested loan (after down payment)
    monthly_payment = calculate_monthly_payment(actual_loan_amount)

    # Calculate maximum property amount (loan + down payment)
    max_property_amount = max_loan_amount + @down_payment

    # Generate amortization schedule
    amortization_schedule = generate_amortization_schedule(actual_loan_amount)

    # Calculate total payment (principal + interest)
    total_payment = monthly_payment * @loan_tenure_years * 12

    # The principal is the actual loan amount (after down payment)
    principal_total = actual_loan_amount
    interest_total = total_payment - principal_total

    # Create payment breakdown percentages
    principal_percentage = (principal_total / total_payment * 100).round(1)
    interest_percentage = (interest_total / total_payment * 100).round(1)

    {
      maximum_loan_amount: max_loan_amount.round(0),
      maximum_property_amount: max_property_amount.round(0),
      monthly_instalment_amount: monthly_payment.round(0),
      payment_breakdown: {
        principal: {
          amount: principal_total.round(2),
          percentage: principal_percentage
        },
        interest: {
          amount: interest_total.round(2),
          percentage: interest_percentage
        },
        total_payment: total_payment.round(2)
      },
      amortization_schedule: amortization_schedule
    }
  end

  private

  def validate_eligibility_params
    @errors[:monthly_net_income] = "must be greater than 0" if @monthly_net_income <= 0
    @errors[:loan_amount] = "must be greater than 0" if @loan_amount <= 0
    @errors[:loan_tenure_years] = "must be between 1 and 40" unless (1..40).include?(@loan_tenure_years)
    @errors[:interest_rate] = "must be between 0.1 and 20" unless (0.1..20).include?(@interest_rate)
    @errors[:down_payment] = "must be less than loan amount" if @down_payment >= @loan_amount if @down_payment > 0
  end

  def validate_mortgage_params
    @errors[:loan_amount] = "must be greater than 0" if @loan_amount <= 0
    @errors[:loan_tenure_years] = "must be between 1 and 40" unless (1..40).include?(@loan_tenure_years)
    @errors[:interest_rate] = "must be between 0.1 and 20" unless (0.1..20).include?(@interest_rate)
  end

  def validate_rental_yield_params
    @errors[:property_price] = "must be greater than 0" if @property_price <= 0
    @errors[:loan_tenure_years] = "must be between 1 and 40" unless (1..40).include?(@loan_tenure_years)
    @errors[:interest_rate] = "must be between 0.1 and 20" unless (0.1..20).include?(@interest_rate)
    @errors[:monthly_rent] = "must be greater than 0" if @monthly_rent <= 0
    @errors[:expected_vacancy_rate] = "must be between 0 and 100" unless (0..100).include?(@expected_vacancy_rate)
    @errors[:down_payment] = "must be less than property price" if @down_payment >= @property_price if @down_payment > 0
  end

  def validate_down_payment_plan_params
    @errors[:property_price] = "must be greater than 0" if @property_price <= 0
    @errors[:down_payment_percentage] = "must be between 1 and 100" unless (1..100).include?(@down_payment_percentage)
    @errors[:current_savings] = "must be greater than or equal to 0" if @current_savings < 0
    @errors[:monthly_savings] = "must be greater than 0" if @monthly_savings <= 0
    @errors[:interest_rate] = "must be between 0 and 20" unless (0..20).include?(@interest_rate)
    @errors[:annual_property_price_inflation] = "must be between 0 and 20" unless (0..20).include?(@annual_property_price_inflation)
  end

  def calculate_annual_expenses
    # Sum all annual property expenses
    @local_authority_tax +
    @insurance +
    @repairs_and_maintenance +
    @other_expenses
  end

  def calculate_monthly_payment(loan_amount)
    # Convert annual interest rate to monthly rate
    monthly_interest_rate = @interest_rate / (12 * 100)

    # Convert loan tenure from years to months
    tenure_months = @loan_tenure_years * 12

    # Monthly payment formula: P * r * (1+r)^n / ((1+r)^n - 1)
    # Where P = principal, r = monthly interest rate, n = loan term in months
    if monthly_interest_rate.zero?
      loan_amount / tenure_months
    else
      loan_amount * monthly_interest_rate * (1 + monthly_interest_rate)**tenure_months /
        ((1 + monthly_interest_rate)**tenure_months - 1)
    end
  end

  def calculate_max_loan_from_payment(monthly_payment)
    # Convert annual interest rate to monthly rate
    monthly_interest_rate = @interest_rate / (12 * 100)

    # Convert loan tenure from years to months
    tenure_months = @loan_tenure_years * 12

    # Rearranging the monthly payment formula to solve for loan amount
    # P = payment * ((1+r)^n - 1) / (r * (1+r)^n)
    if monthly_interest_rate.zero?
      monthly_payment * tenure_months
    else
      monthly_payment * ((1 + monthly_interest_rate)**tenure_months - 1) /
        (monthly_interest_rate * (1 + monthly_interest_rate)**tenure_months)
    end
  end

  def calculate_months_to_save(target_amount)
    # Calculate how many months it will take to save for the down payment
    # taking into account the starting amount, monthly savings, and interest

    remaining = target_amount - @current_savings
    return 0 if remaining <= 0  # Already saved enough

    # Convert annual interest rate to monthly
    monthly_interest_rate = @interest_rate / (12 * 100)

    # Consider property price inflation (adjust target over time)
    monthly_inflation_rate = @annual_property_price_inflation / (12 * 100)

    balance = @current_savings
    months = 0
    property_price = @property_price

    # Simulate month-by-month saving until target is reached
    loop do
      # Apply monthly interest to current balance
      interest = balance * monthly_interest_rate
      balance += interest

      # Add monthly savings
      balance += @monthly_savings

      # Update property price with inflation
      property_price *= (1 + monthly_inflation_rate)

      # Recalculate target down payment based on inflated property price
      target_amount = (property_price * @down_payment_percentage) / 100

      months += 1

      # Check if target is reached or safeguard against infinite loop
      break if balance >= target_amount || months >= 600 # 50 years max
    end

    months
  end

  def format_ready_date(months)
    # Calculate the ready date by adding the number of months to today
    ready_date = Time.now + (months * 30.44 * 24 * 60 * 60) # Average days in a month
    ready_date.strftime("%B %Y")
  end

  def format_years_months(total_months)
    years = total_months / 12
    months = total_months % 12

    if years > 0 && months > 0
      "#{years} #{years == 1 ? 'year' : 'years'} #{months} #{months == 1 ? 'month' : 'months'}"
    elsif years > 0
      "#{years} #{years == 1 ? 'year' : 'years'}"
    else
      "#{months} #{months == 1 ? 'month' : 'months'}"
    end
  end

  def calculate_savings_rate_comparison(target_amount)
    # Calculate how long it would take with different monthly savings amounts
    savings_rates = [1500, 2000, 2500, 3000]
    comparison = {}

    savings_rates.each do |rate|
      # Store the original monthly savings
      original_monthly_savings = @monthly_savings

      # Temporarily set monthly savings to the comparison rate
      @monthly_savings = rate

      # Calculate months needed with this rate
      months = calculate_months_to_save(target_amount)

      # Add to comparison
      comparison[rate.to_s + "/month"] = months.to_s + " months"

      # Restore original monthly savings
      @monthly_savings = original_monthly_savings
    end

    comparison
  end

  def validate_rental_yield_params
    @errors[:property_price] = "must be greater than 0" if @property_price <= 0
    @errors[:loan_tenure_years] = "must be between 1 and 40" unless (1..40).include?(@loan_tenure_years)
    @errors[:interest_rate] = "must be between 0.1 and 20" unless (0.1..20).include?(@interest_rate)
    @errors[:monthly_rent] = "must be greater than 0" if @monthly_rent <= 0
    @errors[:expected_vacancy_rate] = "must be between 0 and 100" unless (0..100).include?(@expected_vacancy_rate)
    @errors[:down_payment] = "must be less than property price" if @down_payment >= @property_price if @down_payment > 0
  end

  def calculate_annual_expenses
    # Sum all annual property expenses
    @local_authority_tax +
    @insurance +
    @repairs_and_maintenance +
    @other_expenses
  end

  def calculate_monthly_payment(loan_amount)
    # Convert annual interest rate to monthly rate
    monthly_interest_rate = @interest_rate / (12 * 100)

    # Convert loan tenure from years to months
    tenure_months = @loan_tenure_years * 12

    # Monthly payment formula: P * r * (1+r)^n / ((1+r)^n - 1)
    # Where P = principal, r = monthly interest rate, n = loan term in months
    if monthly_interest_rate.zero?
      loan_amount / tenure_months
    else
      loan_amount * monthly_interest_rate * (1 + monthly_interest_rate)**tenure_months /
        ((1 + monthly_interest_rate)**tenure_months - 1)
    end
  end

  def calculate_max_loan_from_payment(monthly_payment)
    # Convert annual interest rate to monthly rate
    monthly_interest_rate = @interest_rate / (12 * 100)

    # Convert loan tenure from years to months
    tenure_months = @loan_tenure_years * 12

    # Rearranging the monthly payment formula to solve for loan amount
    # P = payment * ((1+r)^n - 1) / (r * (1+r)^n)
    if monthly_interest_rate.zero?
      monthly_payment * tenure_months
    else
      monthly_payment * ((1 + monthly_interest_rate)**tenure_months - 1) /
        (monthly_interest_rate * (1 + monthly_interest_rate)**tenure_months)
    end
  end

  def generate_amortization_schedule(loan_amount)
    yearly_schedule = []
    remaining_balance = loan_amount
    monthly_payment = calculate_monthly_payment(loan_amount)
    monthly_interest_rate = @interest_rate / (12 * 100)

    (1..@loan_tenure_years).each do |year|
      # Calculate yearly totals
      yearly_principal = 0
      yearly_interest = 0
      months_data = []

      # Calculate 12 months of payments for the current year
      (1..12).each do |month|
        break if remaining_balance <= 0

        # Calculate interest for this month
        interest_payment = remaining_balance * monthly_interest_rate

        # Calculate principal for this month
        principal_payment = [monthly_payment - interest_payment, remaining_balance].min

        # Update yearly totals
        yearly_principal += principal_payment
        yearly_interest += interest_payment

        # Calculate month number overall (1-360 for 30-year loan)
        overall_month = (year - 1) * 12 + month

        # Add to monthly data for this year
        months_data << {
          month: month,
          overall_month: overall_month,
          principal: principal_payment.round(2),
          interest: interest_payment.round(2),
          total_payment: (principal_payment + interest_payment).round(2),
          balance: (remaining_balance - principal_payment).round(2)
        }

        # Update remaining balance
        remaining_balance -= principal_payment
      end

      # Add yearly summary with monthly breakdown to the schedule
      yearly_schedule << {
        year: year,
        principal: yearly_principal.round(2),
        interest: yearly_interest.round(2),
        balance: remaining_balance.round(2),
        months: months_data
      }
    end

    yearly_schedule
  end
end

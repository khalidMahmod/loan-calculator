# config/routes.rb
Rails.application.routes.draw do
  # Root route
  root 'home#index'

  # Property ROI Calculator
  get 'property-roi', to: 'property_roi_calculations#new', as: :property_roi
  post 'property-roi/calculate', to: 'property_roi_calculations#calculate', as: :property_roi_calculate
  get 'property-roi/export-pdf', to: 'property_roi_calculations#export_pdf', as: :property_roi_export_pdf, defaults: { format: 'pdf' }
get 'property-roi/export-excel', to: 'property_roi_calculations#export_excel', as: :property_roi_export_excel, defaults: { format: 'xlsx' }

  # Affordability Calculator
  get 'affordability', to: 'affordability_calculations#new'
  post 'affordability/calculate', to: 'affordability_calculations#calculate'
  post 'affordability/export-pdf', to: 'affordability_calculations#export_pdf'
  post 'affordability/export-excel', to: 'affordability_calculations#export_excel'

  # Mortgage Calculator
  get 'mortgage', to: 'mortgage_calculations#new'
  post 'mortgage/calculate', to: 'loan_calculations#mortgage_calculate'
  post 'mortgage/export-pdf', to: 'mortgage_calculations#export_pdf'
  post 'mortgage/export-excel', to: 'mortgage_calculations#export_excel'
  post 'mortgage/amortization-schedule', to: 'mortgage_calculations#amortization_schedule'

  post 'loan_calculator/eligibility', to: 'loan_calculations#eligibility'
  post 'loan_calculator/mortgage', to: 'loan_calculations#mortgage'
  post 'loan_calculator/rental_yield', to: 'loan_calculations#rental_yield'
  post 'loan_calculator/down_payment_plan', to: 'loan_calculations#down_payment_plan'
end

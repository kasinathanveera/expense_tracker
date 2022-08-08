json.report do
  json.(@report, :id, :status)
  json.expense(@report.expenses, :id, :invoice_number, :description, :amount, :status, :date)
end

json.already_processed_expenses do
  json.array! @report.already_processed_expenses
end

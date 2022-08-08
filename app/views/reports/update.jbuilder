json.report do
    json.(@report, :id, :status)
    json.expense(@report.expenses, :id, :invoice_number, :description, :amount, :status, :date, :approved_amount)
end
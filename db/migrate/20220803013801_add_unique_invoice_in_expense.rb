class AddUniqueInvoiceInExpense < ActiveRecord::Migration[7.0]
  def change
    add_index :expenses, :invoice_number, unique: true
  end
end

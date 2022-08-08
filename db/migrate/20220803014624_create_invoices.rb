class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices, id: false do |t|
      t.integer :invoice_number, primary_key: true
      t.string :biller

      t.timestamps
    end
  end
end

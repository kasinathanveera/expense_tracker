class CreateExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :expenses do |t|
      t.string :description, null: false
      t.integer :amount, null: false
      t.date :date
      t.integer :invoice_number, null: false
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

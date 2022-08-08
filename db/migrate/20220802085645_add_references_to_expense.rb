class AddReferencesToExpense < ActiveRecord::Migration[7.0]
  def change
    add_reference :expenses, :report, null: true, foreign_key: true
  end
end

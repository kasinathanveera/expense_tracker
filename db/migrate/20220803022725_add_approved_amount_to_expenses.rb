class AddApprovedAmountToExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :expenses, :approved_amount, :integer
  end
end

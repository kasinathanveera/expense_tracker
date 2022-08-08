class ExpensePolicy < ApplicationPolicy
  def update?
    record.drafted?
  end

  def submitted?
    record.submitted? || record.verified?
  end
end

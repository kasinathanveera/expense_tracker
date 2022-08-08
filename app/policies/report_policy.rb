class ReportPolicy < ApplicationPolicy
  def update?
    record.drafted?
  end
end

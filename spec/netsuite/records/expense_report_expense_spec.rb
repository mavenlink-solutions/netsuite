require 'spec_helper'

describe NetSuite::Records::ExpenseReportExpense do
  let(:expense) { NetSuite::Records::ExpenseReportExpense.new }

  it 'has the specified fields' do
    [
      :amount, :exchange_rate, :expense_date, :foreign_amount, :gross_amt, :is_billable, :is_non_reimbursable,
      :line, :memo, :quantity, :rate, :receipt, :ref_number, :tax_1_amt, :tax_rate_1, :tax_rate_2, :klass
    ].each do |field|
      expect(expense).to have_field(field)
    end
  end

  it 'has the specified record refs' do
    [:category, :currency, :customer, :department, :location, :tax_code].each do |record_ref|
      expect(expense).to have_record_ref(record_ref)
    end
  end
end

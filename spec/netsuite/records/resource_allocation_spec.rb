require 'spec_helper'

describe NetSuite::Records::ResourceAllocation do
  let(:resource_allocation) { NetSuite::Records::ResourceAllocation.new }

  it "has the right fields" do
    [:allocation_amount, :end_date, :notes, :number_hours, :percent_of_time, :start_date, :allocation_unit, :approval_status].each do |f|
      expect(resource_allocation).to have_field(f)
    end
  end

  it 'has the right record refs' do
    [:allocation_resource, :allocation_type, :custom_form, :next_approver, :project, :request_by].each do |rr|
      expect(resource_allocation).to have_record_ref(rr)
    end
  end
end

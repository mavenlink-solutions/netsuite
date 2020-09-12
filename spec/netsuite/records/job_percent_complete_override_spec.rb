require 'spec_helper'

describe NetSuite::Records::JobPercentCompleteOverride do
  let(:item) { NetSuite::Records::JobPercentCompleteOverride.new }

  it "has the correct fields" do
    %i(
      comments
      percent
    ).each do |field|
      expect(item).to have_field(field)
    end
  end

  describe "#period" do
    it "can be set from attributes" do
      attributes = { internal_id: 10 }
      item.period = attributes
      expect(item.period).to be_kind_of(NetSuite::Records::AccountingPeriod)
      expect(item.period.internal_id).to eq 10
    end

    it "can be set from an AccountingPeriod object" do
      accounting_period = NetSuite::Records::AccountingPeriod.new
      item.period = accounting_period
      expect(item.period).to eq accounting_period
    end
  end
end

require 'spec_helper'

describe NetSuite::Records::ItemFulfillmentItemList do
  it "has all the right fields" do
    [
      :replace_all
    ].each do |field|
      expect(subject).to have_field(field)
    end
  end

  it "has an item attribute" do
    expect(subject.item).to be_kind_of(Array)
  end
end

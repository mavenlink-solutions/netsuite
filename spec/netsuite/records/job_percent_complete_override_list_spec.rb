require "spec_helper"

describe NetSuite::Records::JobPercentCompleteOverrideList do
  let(:list) { NetSuite::Records::JobPercentCompleteOverrideList.new }

  it "has a job_percent_complete_override attribute" do
    expect(list.job_percent_complete_override).to be_kind_of(Array)
  end

  describe "#to_record" do
    before do
      list.job_percent_complete_override << NetSuite::Records::JobPercentCompleteOverride.new(percent: 10)
    end

    it "can represent itself as a SOAP record" do
      record = {
        'listRel:jobPercentCompleteOverride' => [{
          'listRel:percent' => 10
        }]
      }
      expect(list.to_record).to eq record
    end
  end
end

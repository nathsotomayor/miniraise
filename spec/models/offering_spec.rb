require "rails_helper"

RSpec.describe Offering, type: :model do
  def build_offering(**attributes)
    Offering.new(name: "Solar Kettle Co.", target_amount_cents: 50_000_000, min_investment_cents: 10_000, **attributes)
  end

  it "is valid with a name and positive integer amounts" do
    expect(build_offering).to be_valid
  end

  it "requires a name" do
    expect(build_offering(name: "")).to be_invalid
  end

  %i[target_amount_cents min_investment_cents].each do |attribute|
    it "requires #{attribute} to be a positive integer" do
      [ nil, 0, -1, 10.5 ].each do |value|
        expect(build_offering(attribute => value)).to be_invalid, "expected #{value.inspect} to be rejected"
      end
    end
  end

  describe "totals" do
    let(:offering) { build_offering.tap(&:save!) }

    def invest(email, amount_cents)
      offering.investments.create!(investor_name: "Investor", investor_email: email, amount_cents: amount_cents)
    end

    it "is zero with no investments" do
      expect(offering.raised_amount_cents).to eq(0)
      expect(offering.investor_count).to eq(0)
    end

    it "sums every investment and counts distinct investor emails" do
      invest("ana@example.com", 25_000)
      invest(" Ana@Example.com ", 15_000)
      invest("bruno@example.com", 10_000)

      expect(offering.raised_amount_cents).to eq(50_000)
      expect(offering.investor_count).to eq(2)
    end
  end
end

require "rails_helper"

RSpec.describe "db/seeds.rb" do
  it "creates one offering with four investments and is safe to run twice" do
    2.times { Rails.application.load_seed }

    offering = Offering.sole
    expect(offering.investments.count).to eq(4)
    expect(offering.raised_amount_cents).to eq(12_500_000)
    expect(offering.investor_count).to eq(4)
  end
end

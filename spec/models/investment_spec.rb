require "rails_helper"

RSpec.describe Investment, type: :model do
  let(:offering) { Offering.create!(name: "Solar Kettle Co.", target_amount_cents: 50_000_000, min_investment_cents: 10_000) }

  def build_investment(**attributes)
    offering.investments.new(investor_name: "Ana", investor_email: "ana@example.com", amount_cents: 25_000, **attributes)
  end

  it "is valid with a name, email, and amount at or above the minimum" do
    expect(build_investment).to be_valid
    expect(build_investment(amount_cents: 10_000)).to be_valid
  end

  it "requires an offering" do
    expect(Investment.new(investor_name: "Ana", investor_email: "ana@example.com", amount_cents: 25_000)).to be_invalid
  end

  it "requires an investor name" do
    expect(build_investment(investor_name: " ")).to be_invalid
  end

  it "requires a valid email" do
    [ "", "ana", "ana@", "ana example.com", "ana@mail", "ana@mail.", "ana@mail.c",
      "ana@@mail.com", "a,b@mail.com", "ana@mail..com" ].each do |email|
      expect(build_investment(investor_email: email)).to be_invalid, "expected #{email.inspect} to be rejected"
    end
  end

  it "accepts emails with a proper domain and TLD" do
    [ "ana@mail.com", "ana@mail.co", "ana@sub.example.io", "a.b+tag@example.org" ].each do |email|
      expect(build_investment(investor_email: email)).to be_valid, "expected #{email.inspect} to be accepted"
    end
  end

  it "strips and downcases the email" do
    expect(build_investment(investor_email: "  Ana@Example.COM ").investor_email).to eq("ana@example.com")
  end

  it "requires an integer amount" do
    expect(build_investment(amount_cents: nil)).to be_invalid
    expect(build_investment(amount_cents: 25_000.5)).to be_invalid
  end

  it "rejects an amount below the offering minimum" do
    investment = build_investment(amount_cents: 9_999)

    expect(investment).to be_invalid
    expect(investment.errors[:amount_cents]).to eq([ "must be at least 100.00" ])
  end
end

require "rails_helper"

RSpec.describe "GET /api/offerings/:id", type: :request do
  let(:offering) { Offering.create!(name: "Solar Kettle Co.", target_amount_cents: 50_000_000, min_investment_cents: 10_000) }

  it "returns the offering with its totals" do
    offering.investments.create!(investor_name: "Ana", investor_email: "ana@example.com", amount_cents: 25_000)
    offering.investments.create!(investor_name: "Ana", investor_email: "ana@example.com", amount_cents: 15_000)
    offering.investments.create!(investor_name: "Bruno", investor_email: "bruno@example.com", amount_cents: 10_000)

    get api_offering_path(offering)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/json")
    expect(response.parsed_body).to eq(
      "id" => offering.id,
      "name" => "Solar Kettle Co.",
      "target_amount_cents" => 50_000_000,
      "min_investment_cents" => 10_000,
      "raised_amount_cents" => 50_000,
      "investor_count" => 2
    )
  end

  it "returns 404 when the offering does not exist" do
    get api_offering_path(id: 0)

    expect(response).to have_http_status(:not_found)
    expect(response.media_type).to eq("application/json")
  end
end

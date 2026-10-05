require "rails_helper"

RSpec.describe "POST /api/offerings/:offering_id/investments", type: :request do
  let(:offering) { Offering.create!(name: "Solar Kettle Co.", target_amount_cents: 50_000_000, min_investment_cents: 10_000) }

  def post_investment(attrs)
    post api_offering_investments_path(offering),
         params: { investment: attrs }.to_json,
         headers: { "Content-Type" => "application/json", "Accept" => "application/json" }
  end

  it "returns 201 with updated offering totals on success" do
    post_investment(investor_name: "Ana", investor_email: "ana@example.com", amount_cents: 25_000)

    expect(response).to have_http_status(:created)
    expect(response.media_type).to eq("application/json")
    expect(response.parsed_body).to eq(
      "id" => offering.id,
      "name" => "Solar Kettle Co.",
      "target_amount_cents" => 50_000_000,
      "min_investment_cents" => 10_000,
      "raised_amount_cents" => 25_000,
      "investor_count" => 1
    )
  end

  it "reflects multiple investors in totals" do
    offering.investments.create!(investor_name: "Bruno", investor_email: "bruno@example.com", amount_cents: 10_000)

    post_investment(investor_name: "Ana", investor_email: "ana@example.com", amount_cents: 25_000)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include("raised_amount_cents" => 35_000, "investor_count" => 2)
  end

  it "returns 422 with errors when amount is below the minimum" do
    post_investment(investor_name: "Ana", investor_email: "ana@example.com", amount_cents: 100)

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq(
      "errors" => { "amount_cents" => [ "must be at least 100.00" ] }
    )
  end

  it "returns 422 with errors when required fields are blank" do
    post_investment(investor_name: "", investor_email: "", amount_cents: 25_000)

    expect(response).to have_http_status(422)
    errors = response.parsed_body["errors"]
    expect(errors["investor_name"]).not_to be_empty
    expect(errors["investor_email"]).not_to be_empty
  end

  it "returns 422 with an error for an invalid email" do
    post_investment(investor_name: "Ana", investor_email: "not-an-email", amount_cents: 25_000)

    expect(response).to have_http_status(422)
    expect(response.parsed_body["errors"]["investor_email"]).not_to be_empty
  end

  it "normalizes investor_email before saving" do
    post_investment(investor_name: "Ana", investor_email: "  ANA@Example.COM  ", amount_cents: 25_000)

    expect(response).to have_http_status(:created)
    expect(offering.investments.last.investor_email).to eq("ana@example.com")
  end

  it "returns 404 when the offering does not exist" do
    post api_offering_investments_path(offering_id: 0),
         params: { investment: { investor_name: "Ana", investor_email: "ana@example.com", amount_cents: 25_000 } }.to_json,
         headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:not_found)
  end
end

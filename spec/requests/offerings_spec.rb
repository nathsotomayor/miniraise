require "rails_helper"

RSpec.describe "GET /offerings/:id", type: :request do
  it "renders the checkout mount point with the offering id" do
    offering = Offering.create!(name: "Solar Kettle Co.", target_amount_cents: 50_000_000, min_investment_cents: 10_000)

    get offering_path(offering)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(%(id="investment-checkout" data-offering-id="#{offering.id}"))
    expect(response.body).to include("<title>Solar Kettle Co.</title>")
  end

  it "returns 404 when the offering does not exist" do
    get offering_path(id: 0)

    expect(response).to have_http_status(:not_found)
  end
end

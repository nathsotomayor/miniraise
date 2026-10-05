require "rails_helper"

RSpec.describe "Home page", type: :request do
  it "renders the Svelte mount point" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('id="svelte-root"')
  end
end

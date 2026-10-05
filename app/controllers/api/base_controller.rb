module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Not found" }, status: :not_found
    end
  end
end

module Api
  class OfferingsController < BaseController
    def show
      render json: Offering.find(params[:id]).summary
    end
  end
end

module Api
  class InvestmentsController < BaseController
    def create
      offering = Offering.find(params[:offering_id])
      investment = offering.investments.build(investment_params)
      if investment.save
        render json: offering.summary, status: :created
      else
        render json: { errors: investment.errors.messages }, status: :unprocessable_entity
      end
    end

    private

    def investment_params
      params.require(:investment).permit(:investor_name, :investor_email, :amount_cents)
    end
  end
end

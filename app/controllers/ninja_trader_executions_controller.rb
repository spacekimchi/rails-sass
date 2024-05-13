class NinjaTraderExecutionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    user = User.find_by(ninja_trader_id: params['ninja_trader_id'])
    TradeProcessorService.queue_executions_processing(user, params['executions'])
    render json: { message: "Execution processing started." }, status: :accepted
  end
end

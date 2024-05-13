require 'rails_helper'

RSpec.describe NinjaTraderExecutionsController, type: :controller do
  let(:user) { create(:user, ninja_trader_id: Faker::Number.hexadecimal) }

  describe '#create' do
    it 'queues a trade execution job' do
      expect(TradeProcessorService).to receive(:queue_executions_processing)
      post :create, params: { ninja_trader_id: user.ninja_trader_id, executions: [] }
    end
  end
end

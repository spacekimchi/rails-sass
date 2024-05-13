require 'rails_helper'

RSpec.describe StripeService, type: :service do
  let(:stripe_timestamp) { Faker::Number.rand_in_range(1000000000, 1609459200) }

  describe '.get_time' do
    it 'converts a Stripe timestamp to a Time object' do
      expect(described_class.get_time(stripe_timestamp)).to eq(Time.at(stripe_timestamp))
    end
  end

  describe '.get_datetime' do
    it 'converts a Stripe timestamp to a DateTime object' do
      expect(described_class.get_datetime(stripe_timestamp)).to eq(Time.at(stripe_timestamp).to_datetime)
    end
  end

  describe '.get_stripe_time_now' do
    it 'returns the current time as a timestamp' do
      rand_date = Faker::Number.rand_in_range(1000000000, 1609459200)
      allow(Time).to receive(:now).and_return(Time.at(rand_date))
      expect(described_class.get_stripe_time_now).to eq(rand_date)
    end
  end

  describe '.price_type_to_checkout_session_mode' do
    context 'when the type is ONE_TIME' do
      it 'returns PAYMENT' do
        expect(described_class.price_type_to_checkout_session_mode(described_class::ONE_TIME)).to eq(described_class::PAYMENT)
      end
    end

    context 'when the type is RECURRING' do
      it 'returns SUBSCRIPTION' do
        expect(described_class.price_type_to_checkout_session_mode(described_class::RECURRING)).to eq(described_class::SUBSCRIPTION)
      end
    end

    context 'when the type is unrecognized' do
      it 'returns ERROR' do
        expect(described_class.price_type_to_checkout_session_mode('unknown_type')).to eq(described_class::ERROR)
      end
    end
  end
end

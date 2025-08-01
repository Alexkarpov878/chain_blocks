require 'rails_helper'

RSpec.describe Transactions::IngestionService do
  subject(:service) { described_class.new(chain: chain) }

  let(:chain) { create(:chain, slug: 'near') }

  describe '#call' do
    context 'when API returns transactions' do
      it 'persists new blocks' do
        VCR.use_cassette('near_transactions') do
          expect { service.call }.to change(Block, :count)
        end
      end
    end

    context 'when API returns no transactions' do
      before do
        api_client = instance_double(ApiClient)
        allow(ApiClient).to receive(:new).and_return(api_client)
        allow(api_client).to receive(:get).and_return([])
      end

      it 'does not persist data' do
        expect { service.call }.not_to change(Block, :count)
      end
    end
  end
end

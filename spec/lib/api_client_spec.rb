require 'rails_helper'

describe ApiClient do
  let(:base_url) { "#{ENV['CHAIN__NEAR_API_ENDPOINT']}?api_key=<NEAR_API_KEY>" }
  let(:api_client) { described_class.new(url: base_url) }

  describe '#get' do
    subject(:response) { api_client.get }

    it 'returns response body', vcr: { cassette_name: 'near_transactions', record: :new_episodes } do
      expect(response).to be_present
    end
  end
end

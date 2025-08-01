require 'rails_helper'

RSpec.describe BlockchainAdapter::Near do
  subject(:adapter) { described_class.new(chain) }

  let(:chain) { create(:chain, :near) }
  let(:gas_burnt) { '2427934415604' }
  let(:time) { '2021-01-11T10:20:04.132926-06:00' }

  describe '#fetch_transactions' do
    subject(:transactions) { adapter.fetch_transactions }

    context 'when API returns valid transactions', vcr: { cassette_name: 'near_transactions' } do
      it 'returns an array of raw transactions with expected keys' do
        expect(transactions).to be_present
        expect(transactions.first).to include('hash', 'block_hash', 'height', 'sender', 'receiver', 'actions')
      end
    end
  end

  describe '#normalize' do
    subject(:normalized) { adapter.normalize(raw_transaction) }

    let(:raw_transaction) do
      {
        'hash' => 'example_hash',
        'block_hash' => 'example_block_hash',
        'height' => 12345,
        'sender' => 'sender.near',
        'receiver' => 'receiver.near',
        'gas_burnt' => gas_burnt,
        'time' => time,
        'success' => true,
        'actions' => actions
      }
    end

    shared_examples 'a normalized transaction' do
      it 'normalizes core fields' do
        expect(normalized).to include(
          transaction_hash: 'example_hash',
          block_hash: 'example_block_hash',
          height: 12345,
          sender_address: 'sender.near',
          receiver_address: 'receiver.near',
          gas_used: gas_burnt,
          executed_at: time,
          success: true
        )
      end
    end

    context 'with a transfer action' do
      let(:actions) { [ { 'type' => 'Transfer', 'data' => { 'deposit' => '1000000000000000000000000' } } ] }

      it_behaves_like 'a normalized transaction'

      it 'normalizes transfer action' do
        expect(normalized[:actions].first).to eq(
          'type' => 'Transfer',
          'data' => { 'deposit' => '1000000000000000000000000' }
        )
      end
    end

    context 'with a function call action' do
      let(:actions) { [ { 'type' => 'FunctionCall', 'data' => { 'method_name' => 'ping', 'gas' => 100_000_000_000_000, 'deposit' => '0' } } ] }

      it_behaves_like 'a normalized transaction'

      it 'normalizes function call action' do
        expect(normalized[:actions].first).to eq(
          'type' => 'FunctionCall',
          'data' => { 'method_name' => 'ping', 'gas' => 100_000_000_000_000, 'deposit' => '0' }
        )
      end
    end

    context 'with multiple actions of different types' do
      let(:actions) do
        [
          { 'type' => 'Transfer', 'data' => { 'deposit' => '1000000000000000000000000' } },
          { 'type' => 'FunctionCall', 'data' => { 'method_name' => 'ping', 'gas' => 100_000_000_000_000, 'deposit' => '0' } }
        ]
      end

      it_behaves_like 'a normalized transaction'

      it 'normalizes all actions' do
        expect(normalized[:actions].size).to eq(2)
        expect(normalized[:actions][0]['type']).to eq('Transfer')
        expect(normalized[:actions][1]['type']).to eq('FunctionCall')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Transactions::IngestionService do
  subject(:service) { described_class.new(chain:, adapter:) }

  let(:chain) { create(:chain, :near) }
  let(:adapter) { BlockchainAdapter::Near.new(chain) }

  describe '#call' do
    before { allow(adapter).to receive(:fetch_transactions).and_return(raw_transactions) }

    context 'when no transactions are returned' do
      let(:raw_transactions) { [] }

      it 'creates no records' do
        expect { service.call }.not_to change { [ Block.count, ChainTransaction.count, Action.count ] }
      end
    end

    context 'when multiple transactions share the same block' do
      let(:block_hash) { 'shared_block_hash' }
      let(:height) { 42 }
      let(:raw_transactions) do
        [
          build_raw_tx('tx1', block_hash, height, sender: 'sender1', receiver: 'receiver1', actions: [ { 'type' => 'Transfer', 'data' => { 'deposit' => '100' } } ]),
          build_raw_tx('tx2', block_hash, height, sender: 'sender2', receiver: 'receiver2', actions: [ { 'type' => 'FunctionCall', 'data' => { 'method_name' => 'ping', 'gas' => 100000000000000, 'deposit' => '0' } } ])
        ]
      end

      it 'creates one block with multiple transactions' do
        expect { service.call }
          .to change(Block, :count).by(1)
          .and change(ChainTransaction, :count).by(2)
          .and change(Action, :count).by(2)

        block = Block.find_by(block_hash:)
        expect(block.chain_transactions.pluck(:transaction_hash)).to match_array(%w[tx1 tx2])
      end
    end

    context 'when transaction has multiple actions of different types' do
      let(:raw_transactions) do
        [
          build_raw_tx('tx_hash', 'block_hash', 12345, actions: [
            { 'type' => 'Transfer', 'data' => { 'deposit' => '1000000000000000000000000' } },
            { 'type' => 'FunctionCall', 'data' => { 'method_name' => 'ping', 'gas' => 100000000000000, 'deposit' => '0' } }
          ])
        ]
      end

      it 'creates actions with correct attributes' do
        expect { service.call }.to change(Action, :count).by(2)

        transfer_action = Action.find_by(action_type: 'Transfer')
        expect(transfer_action.deposit).to eq(1_000_000_000_000_000_000_000_000)
        expect(transfer_action.data).to eq({ 'deposit' => '1000000000000000000000000' }.as_json)

        function_action = Action.find_by(action_type: 'FunctionCall')
        expect(function_action.data).to include('method_name' => 'ping')
      end
    end

    context 'when transaction already exists' do
      let(:existing_block) { create(:block, chain:, block_hash: 'existing_block', height: 12345) }
      let(:raw_transactions) { [ build_raw_tx('existing_tx', 'existing_block', 12345) ] }

      before { create(:chain_transaction, block: existing_block, transaction_hash: 'existing_tx') }

      it 'does not duplicate the transaction' do
        expect { service.call }.not_to change(ChainTransaction, :count)
      end
    end
  end

  private

  def build_raw_tx(tx_hash, block_hash, height, sender: 'sender', receiver: 'receiver', actions: [])
    {
      'hash' => tx_hash,
      'block_hash' => block_hash,
      'height' => height,
      'sender' => sender,
      'receiver' => receiver,
      'gas_burnt' => '2427934415604',
      'time' => Time.current.iso8601,
      'success' => true,
      'actions' => actions
    }
  end
end

module Transactions
  class IngestionService
    attr_accessor :chain, :api_client

    def self.call(chain_slug: 'near')
      # TODO: Refactor to support multiple chains
      new(chain: Chain.find_by!(slug: chain_slug)).call
    end

    def initialize(chain:)
      @chain = chain
      @api_client = ApiClient.new(url: "#{ENV.fetch("CHAIN__NEAR_API_ENDPOINT")}?api_key=#{Rails.application.credentials.near.api_key}")
    end

    def call
      transactions = fetch_and_normalize_transactions
      if transactions.empty?
        Rails.logger.info("No transactions found for chain: #{@chain.slug}")
        return
      end
      process_transactions(transactions)
      Rails.logger.info("Ingestion complete for chain: #{@chain.slug}")
    rescue StandardError => e
      Rails.logger.error("Ingestion failed for chain: #{@chain.slug}, error: #{e.message}")
      raise
    end

    private

    def fetch_and_normalize_transactions
      raw_transactions = @api_client.get
      return [] if raw_transactions.blank?

      raw_transactions.map { |tx| normalize(tx) }
    end

    def normalize(tx_data)
      {
        height: tx_data['height'],
        block_hash: tx_data['block_hash'],
        transaction_hash: tx_data['hash'],
        sender_address: tx_data['sender'],
        receiver_address: tx_data['receiver'],
        gas_used: tx_data['gas_burnt'],
        success: tx_data['success'],
        executed_at: tx_data['time'],
        actions: tx_data.fetch('actions', [])
      }
    end

    def process_transactions(transactions)
      transactions.each do |transaction_data|
        ActiveRecord::Base.transaction do
          persist_transaction(transaction_data)
        end
      end
    end

    def persist_transaction(data)
      block = @chain.blocks.find_or_create_by!(block_hash: data[:block_hash]) do |b|
        b.height = data[:height]
      end

      chain_transaction = block.chain_transactions.find_or_create_by!(transaction_hash: data[:transaction_hash]) do |t|
        t.sender = data[:sender_address]
        t.receiver = data[:receiver_address]
        t.gas_used = data[:gas_used]
        t.success = data[:success]
        t.executed_at = data[:executed_at]
      end

      data[:actions].each do |action|
        action_type = action['type']
        payload = action['data'] || {}
        deposit = action_type == 'Transfer' ? payload['deposit'] : nil
        chain_transaction.actions.create!(
          action_type: action_type,
          data: payload,
          deposit: deposit,
          executed_at: data[:executed_at]
        )
      end
    end
  end
end

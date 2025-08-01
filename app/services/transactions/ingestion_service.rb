module Transactions
  class IngestionService
    attr_reader :chain, :adapter

    def self.call(chain_slug:)
      chain = Chain.find_by!(slug: chain_slug)
      adapter = adapter_for(chain)
      new(chain:, adapter:).call
    end

    def self.adapter_for(chain)
      adapter_class_name = "BlockchainAdapter::#{chain.slug.capitalize}" # This can be reworked in a production app
      adapter_class_name.constantize.new(adapter_class_name)
    rescue NameError => e
      raise ArgumentError, "No adapter found for chain: #{chain.slug} (#{e.message})"
    end

    def initialize(chain:, adapter:)
      @chain = chain
      @adapter = adapter
    end

    def call
      normalized_transactions = fetch_and_normalize_transactions
      if normalized_transactions.empty?
        Rails.logger.info("No transactions found for chain: #{chain.slug}")
        return
      end

      process_transactions(normalized_transactions)
      Rails.logger.info("Ingestion complete for chain: #{chain.slug}")
    rescue StandardError => e
      Rails.logger.error("Ingestion failed for chain: #{chain.slug}, error: #{e.message}")
      raise
    end

    private

    def fetch_and_normalize_transactions
      raw_transactions = adapter.fetch_transactions
      return [] if raw_transactions.blank?

      raw_transactions.map { |tx| adapter.normalize(tx) }
    end

    def process_transactions(normalized_transactions)
      normalized_transactions.each do |transaction_data|
        ActiveRecord::Base.transaction do
          persist_transaction(transaction_data)
        end
      end
    end

    def persist_transaction(data)
      block = chain.blocks.find_or_create_by!(block_hash: data[:block_hash]) do |b|
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
        action_type = action["type"]
        payload = action["data"] || {}
        deposit = action_type == "Transfer" ? payload["deposit"] : nil
        chain_transaction.actions.find_or_create_by!(
          action_type:,
          data: payload,
          deposit:,
          executed_at: data[:executed_at]
        )
      end
    end
  end
end

module BlockchainAdapter
  class Near < Base
    attr_reader :api_client

    def initialize(chain)
      super
      @api_client = ApiClient.new(url: api_url)
    end

    def fetch_transactions
      api_client.get || []
    end

    def normalize(raw_transaction)
      {
        height: raw_transaction.fetch("height"),
        block_hash: raw_transaction.fetch("block_hash"),
        transaction_hash: raw_transaction.fetch("hash"),
        sender_address: raw_transaction.fetch("sender"),
        receiver_address: raw_transaction.fetch("receiver"),
        gas_used: raw_transaction.fetch("gas_burnt"),
        success: raw_transaction.fetch("success"),
        executed_at: raw_transaction.fetch("time"),
        actions: raw_transaction.fetch("actions", [])
      }
    end

    private

    def api_url
      "#{ENV.fetch("CHAIN__NEAR_API_ENDPOINT")}?api_key=#{Rails.application.credentials.near.api_key}"
    end
  end
end

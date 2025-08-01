module BlockchainAdapter
  class Base
    attr_accessor :chain, :api_key, :url, :client

    def initialize(chain)
      @chain = chain
    end

    def fetch_transactions
      raise NotImplementedError, "Subclasses must implement fetch_transactions"
    end

    def normalize(raw_transaction)
      raise NotImplementedError, "Subclasses must implement normalize"
    end
  end
end

class SyncChainJob < ApplicationJob
  queue_as :default

  def perform(chain_slug)
    Transactions::IngestionService.call(chain_slug: chain_slug)
  end
end

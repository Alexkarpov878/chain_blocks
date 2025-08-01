class TransfersController < ApplicationController
  before_action :set_chains
  before_action :set_chain

  def index
    @transfers = @chain.chain_transactions
                       .successful
                       .displayable_transfers
                       .includes(block: :chain)

    @average_gas_used = @chain.average_gas_used
  end

  private

  def set_chains
    @chains = Chain.order(:name)
  end

  def set_chain
    @chain = @chains.find_by(slug: params[:chain_slug]) || @chains.first
    @chain ||= Chain.new(name: 'No Chains', slug: 'none', token_symbol: '')
  end
end

class CurrencyPresenter
  attr_reader :raw_amount, :decimals, :symbol

  def initialize(raw_amount:, chain:)
    @raw_amount = raw_amount.to_s
    @decimals = chain.token_decimals
    @symbol = chain.token_symbol
  end

  def display_amount
    return "N/A" if raw_amount.blank? || !decimals&.positive?
    return "0 #{symbol}" if raw_amount == '0'

    formatted_value = format_bigdecimal
    "#{formatted_value} #{symbol}"
  end

  private

  def format_bigdecimal
    value = BigDecimal(raw_amount) / (10**decimals)
    value.to_s("F").sub(/\.?0+$/, '')
  end
end

require 'json'

class TransactionAnalyzer
  FIELDS = [
    'id', 'created_at', 'updated_at', 'time', 'height', 'hash', 'block_hash',
    'sender', 'receiver', 'gas_burnt', 'actions', 'actions_count', 'success'
  ].freeze

  TYPES = {
    'id' => Integer,
    'created_at' => String,
    'updated_at' => String,
    'time' => String,
    'height' => Integer,
    'hash' => String,
    'block_hash' => String,
    'sender' => String,
    'receiver' => String,
    'gas_burnt' => String, # numeric string.
    'actions' => Array,
    'actions_count' => Integer,
    'success' => [ TrueClass, FalseClass ]
  }.freeze

  attr_reader :success_count, :failure_count

  def initialize(file_path)
    @file_path = file_path
    @data = []
    @issues = []
    @id_frequencies = Hash.new(0)
    @hash_frequencies = Hash.new(0)
    @block_hash_frequencies = Hash.new(0)
    @key_occurrences = Hash.new(0)
    @success_count = 0
    @failure_count = 0
  end

  def run
    load_data
    return if @data.empty?

    analyze_data
    generate_report
  rescue StandardError => e
    puts "Error during analysis: #{e.message}"
  end

  private

  def load_data
    json_content = File.read(@file_path)
    @data = JSON.parse(json_content)
  end

  def analyze_data
    @data.each_with_index do |transaction, index|
      count_success(transaction)
      track_id_frequency(transaction['id']) if transaction['id']
      track_hash_frequency(transaction['hash']) if transaction['hash']
      track_block_hash_frequency(transaction['block_hash']) if transaction['block_hash']
      check_fields(transaction, index)
      check_data_types(transaction, index)
      check_actions_structure(transaction, index)
      check_action_data_schemas(transaction, index)
      track_key_occurrences(transaction)
    end
  end

  def count_success(transaction)
    success_value = transaction['success']
    if success_value == true
      @success_count += 1
    elsif success_value == false
      @failure_count += 1
    end
  end

  def track_id_frequency(id)
    @id_frequencies[id] += 1
  end

  def track_hash_frequency(hash_value)
    @hash_frequencies[hash_value] += 1
  end

  def track_block_hash_frequency(block_hash)
    @block_hash_frequencies[block_hash] += 1
  end

  def check_action_data_schemas(transaction, index)
    actions = transaction['actions']
    return unless actions.is_a?(Array)

    actions.each_with_index do |action, action_index|
      next unless action.is_a?(Hash) && action.key?('type') && action.key?('data')

      data = action['data']
      case action['type']
      when 'Transfer'
        unless data.is_a?(Hash) && data.key?('deposit')
          log_issue(__method__, index, transaction, "Action #{action_index} (Transfer) missing 'deposit'.")
        end
      when 'FunctionCall'
        unless data.is_a?(Hash) && %w[gas deposit method_name].all? { |key| data.key?(key) }
          log_issue(__method__, index, transaction, "Action #{action_index} (FunctionCall) missing fields.")
        end
      when 'AddKey'
        unless data.is_a?(Hash) && %w[access_key public_key].all? { |key| data.key?(key) }
          log_issue(__method__, index, transaction, "Action #{action_index} (AddKey) missing fields.")
        end
      else
        log_issue(__method__, index, transaction, "Unknown action type '#{action['type']}'.")
      end
    end
  end

  def check_fields(transaction, index)
    FIELDS.each do |field|
      next if transaction.key?(field)

      log_issue(__method__, index, transaction, "Missing '#{field}'.")
    end
  end

  def check_data_types(transaction, index)
    TYPES.each do |field, expected_type|
      next unless transaction.key?(field)

      value = transaction[field]
      if expected_type.is_a?(Array)
        next if expected_type.any? { |type| value.is_a?(type) }

        log_issue(__method__, index, transaction, "'#{field}' expected boolean, got #{value.class}.")
      elsif !value.is_a?(expected_type)
        log_issue(__method__, index, transaction, "'#{field}' expected #{expected_type}, got #{value.class}.")
      elsif field == 'gas_burnt' && !value.match?(/\A\d+\z/)
        log_issue(__method__, index, transaction, "'#{field}' must be a numeric string.")
      end
    end
  end

  def check_actions_structure(transaction, index)
    actions = transaction['actions']
    unless actions.is_a?(Array)
      log_issue(__method__, index, transaction, "'actions' must be an array.")
      return
    end

    if transaction['actions_count'] != actions.size
      log_issue(__method__, index, transaction, "'actions_count' (#{transaction['actions_count']}) mismatches actions array size (#{actions.size}).")
    end

    actions.each_with_index do |action, action_index|
      next if action.is_a?(Hash) && action.key?('data') && action.key?('type')

      log_issue(__method__, index, transaction, "Action #{action_index} missing 'data' or 'type'.")
    end
  end

  def track_key_occurrences(data, prefix = '')
    case data
    when Hash
      data.each do |key, value|
        full_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
        @key_occurrences[full_key] += 1
        track_key_occurrences(value, full_key)
      end
    when Array
      data.each { |item| track_key_occurrences(item, prefix) }
    end
  end

  def generate_report
    puts "Total Transactions: #{@data.size}"
    puts "Successful: #{@success_count}"
    puts "Failed: #{@failure_count}"

    report_id_duplicates
    report_hash_duplicates
    report_block_hash_duplicates
    report_key_occurrences
    report_validation_issues
  end

  def report_id_duplicates
    duplicates = @id_frequencies.select { |_, freq| freq > 1 }.keys
    if duplicates.empty?
      puts "✅ No duplicate IDs found."
    else
      puts "❌ Duplicate IDs: #{duplicates.join(', ')}."
    end
  end

  def report_hash_duplicates
    duplicates = @hash_frequencies.select { |_, freq| freq > 1 }.keys
    if duplicates.empty?
      puts "✅ No duplicate hashes found."
    else
      puts "❌ Duplicate hashes: #{duplicates.join(', ')}."
    end
  end

  def report_block_hash_duplicates
    duplicates = @block_hash_frequencies.select { |_, freq| freq > 1 }.keys
    if duplicates.empty?
      puts "✅ No duplicate block_hashes found."
    else
      puts "❌ Duplicate block_hashes: #{duplicates.join(', ')}."
    end
  end

  def report_key_occurrences
    puts "\n--- Key Occurrences ---"
    @key_occurrences.sort_by(&:first).each do |key, count|
      puts "  - '#{key}': #{count} times"
    end
  end

  def report_validation_issues
    puts "\n--- Validation Issues ---"
    if @issues.empty?
      puts "✅ No issues detected."
    else
      @issues.each { |issue| puts "❌ #{issue}" }
    end
  end

  def log_issue(method_name, index, transaction, message)
    id = transaction.fetch('id', 'N/A')
    @issues << "#{method_name} - Transaction at index #{index} (ID: #{id}): #{message}"
  end
end

analyzer = TransactionAnalyzer.new('data/near_transactions.json')
analyzer.run

# Output:

# Total Transactions: 100
# Successful: 97
# Failed: 3
# ✅ No duplicate IDs found.
# ✅ No duplicate hashes found.
# ❌ Duplicate block_hashes: XsLC84r52ZwhsdyUZU6oLeyvxt8cSPVVXZjpfTBVmvr, 5hsfk358R39pBehoi35sYisTPwF8dkUuNtV5wHs3PEV8, HtzQJTCUTMuAUoURfYRUpdUpmPUSySWBFDZPKs3A8iQe.

# --- Key Occurrences ---
#   - 'actions': 100 times
#   - 'actions.data': 101 times
#   - 'actions.data.access_key': 1 times
#   - 'actions.data.access_key.nonce': 1 times
#   - 'actions.data.access_key.permission': 1 times
#   - 'actions.data.deposit': 100 times
#   - 'actions.data.gas': 87 times
#   - 'actions.data.method_name': 87 times
#   - 'actions.data.public_key': 1 times
#   - 'actions.type': 101 times
#   - 'actions_count': 100 times
#   - 'block_hash': 100 times
#   - 'created_at': 100 times
#   - 'gas_burnt': 100 times
#   - 'hash': 100 times
#   - 'height': 100 times
#   - 'id': 100 times
#   - 'receiver': 100 times
#   - 'sender': 100 times
#   - 'success': 100 times
#   - 'time': 100 times
#   - 'updated_at': 100 times

# --- Validation Issues ---
# ✅ No issues detected.

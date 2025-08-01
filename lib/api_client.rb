class ApiClient
  def initialize(url:)
    @connection = ::Faraday.new(url:) do |faraday|
      faraday.request :retry, { max: 2, interval: 0.5, exceptions: [ Faraday::TimeoutError, Faraday::ConnectionFailed ] }
      faraday.response :json, content_type: /\bjson$/
      if Rails.env.development?
        faraday.response :logger, Rails.logger, headers: true, bodies: true, log_level: :debug
      end
    end
  end

  def get(path = nil)
    response = @connection.get(path)
    response.body
  rescue Faraday::Error => e
    raise ConnectionError, "Faraday connection failed: #{e.message}"
  end
end

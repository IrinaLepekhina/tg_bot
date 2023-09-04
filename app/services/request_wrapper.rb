# app/services/request_wrapper.rb

class RequestWrapper
  include Loggable
  
  COMMON_HEADERS = {
    'Content-Type' => 'application/json',
    'Accept' => 'application/json'
  }

  def initialize
    @auth_service = BotAuthService.new
  end

  def post(url, body, headers = {})
    log_info("Sending POST request", url: url)
    
    response = send_request(:post, url, body, headers)
      
    log_info("Finished POST request", url: url, status: response.status)
    response
  end

  private

  def send_request(method, url, body, headers)
    connection.send(method, url, body, merged_headers(headers))
  end

  def merged_headers(extra_headers = {})
    COMMON_HEADERS.merge(extra_headers).merge(@auth_service.authenticated_header)
  end

  def connection
    Faraday.new do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end
end

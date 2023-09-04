# app/services/bot_auth_service.rb

class BotAuthService
  include Loggable
  
  BASE_URL = "http://web:3000/api"

  def initialize
    log_info("Initializing BotAuthService")
    @storage_service = RedisStorageService.new
    @jwt_token       = fetch_token_from_storage
    @refresh_token   = fetch_refresh_token_from_storage
  end

  def initialize_bot
    return true if jwt_token_present? && !token_expired?

    # Attempt to signup first
    signup(ENV['BOT_NAME'], ENV['BOT_EMAIL'], ENV['BOT_NICKNAME'], ENV['BOT_PASSWORD'])
  
    # If signup didn't work, attempt to login
    unless jwt_token_present?
      login(ENV['BOT_EMAIL'], ENV['BOT_PASSWORD'])
    end
  
    jwt_token_present?
  end
  
  def signup(name, email, nickname, password)
    log_info("Attempting to signup", email: email)
  
    response = Faraday.post("#{BASE_URL}/signup", 
      { user: { name: name, email: email, nickname: nickname, password: password } }.to_json,
      { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )

    handle_response(response)
  end

  def login(email, password)
    log_info("Attempting to login", email: email)
    
    response = Faraday.post("#{BASE_URL}/login", 
      { auth_params: { email: email, password: password } }.to_json,
      { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )

    handle_response(response)
  end

  def authenticated_header
    { "Authorization" => "Bearer #{@jwt_token}" }
  end

  private

  def handle_response(response)
    case response.status
    when 201
      data = JSON.parse(response.body)
      @jwt_token     = response.headers['Authorization']&.gsub('Bearer ', '')
      @refresh_token = data["refresh_token"]
  
      save_tokens_to_storage
  
      # Log the token fetched from storage for validation
      log_info("Request successful. JWT and refresh tokens set.")
    when 400
      log_error("Bad Request", response_body: response.body)
    when 401
      log_error("Unauthorized", response_body: response.body)
    else
      log_error("Unexpected response", status: response.status, response_body: response.body)
    end
  end
  
  def jwt_token_present?
    @jwt_token.present?
  end

  def token_expired?
    # Mock check; actual implementation will depend on token's structure.
    false
  end

  def save_tokens_to_storage
    log_info("Saving JWT_TOKEN and REFRESH_TOKEN to Redis.")
    @storage_service.client.set("JWT_TOKEN", @jwt_token)
    @storage_service.client.set("REFRESH_TOKEN", @refresh_token)
  end
  
  def fetch_token_from_storage
    token = @storage_service.client.get("JWT_TOKEN")
    log_info("Fetched JWT_TOKEN from Redis", status: token ? 'Exists' : 'Does not exist')
  
    unless token
      log_info("Token not found in Redis. Attempting to re-initialize bot.")
      initialize_bot
      token = @jwt_token # Fetch the newly initialized token
    end
  
    token
  end
    
  def fetch_refresh_token_from_storage
    @storage_service.client.get("REFRESH_TOKEN")
  end
end

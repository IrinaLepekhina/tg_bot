# app/services/bot_auth_service.rb

class BotAuthService
  include Loggable
  
  BASE_URL =  ENV['AI_CHAT_URL'] || "http://ai_chat:3000/api"
  
  def initialize
    log_info("Initializing BotAuthService")
    @storage_service = RedisStorageService.new
    @jwt_token       = fetch_token_from_storage
    @refresh_token   = fetch_refresh_token_from_storage
  end

  def initialize_bot
    # Logging the start of the initialization process
    log_info("Starting bot initialization")
  
    if jwt_token_present?
      # Logging the presence of a valid JWT token
      log_info("JWT token already present and not expired")
      return true 
    end
  
    # Logging the attempt to sign up the bot
    log_info("Attempting to signup bot with name: #{ENV['BOT_NAME']}, email: #{ENV['BOT_EMAIL']}")
    signup(ENV['BOT_NAME'], ENV['BOT_EMAIL'], ENV['BOT_NICKNAME'], ENV['BOT_PASSWORD'])
  
    # Logging the condition where sign up failed and trying to log in
    unless jwt_token_present?
      log_info("Signup failed or JWT token missing. Attempting to login bot with email: #{ENV['BOT_EMAIL']}")
      login(ENV['BOT_EMAIL'], ENV['BOT_PASSWORD'])
    end
  
    # Check again if the JWT token is present
    if jwt_token_present?
      log_info("Bot initialization successful with valid JWT token")
      true
    else
      log_error("Bot initialization failed. No JWT token present after signup and login attempts")
      false
    end
  end
  
  # def initialize_bot
  #   return true if jwt_token_present? && !token_expired?

  #   # Attempt to signup first
  #   signup(ENV['BOT_NAME'], ENV['BOT_EMAIL'], ENV['BOT_NICKNAME'], ENV['BOT_PASSWORD'])
  
  #   # If signup didn't work, attempt to login
  #   unless jwt_token_present?
  #     login(ENV['BOT_EMAIL'], ENV['BOT_PASSWORD'])
  #   end
  
  #   jwt_token_present?
  # end

  def send_request(endpoint, payload)
    log_info("Sending request to #{BASE_URL}/#{endpoint}", email: payload.dig(:user, :email) || payload.dig(:auth_params, :email))
    
    begin
        headers = {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
        }

        response = Faraday.post("#{BASE_URL}/#{endpoint}", payload.to_json, headers)
        return response
    rescue Faraday::ConnectionFailed => e
        log_error("Connection failed: #{e.message}")
        return OpenStruct.new(status: 500, body: "Connection failed: #{e.message}")
    rescue => e
        log_error("Error sending request: #{e.message}")
        return OpenStruct.new(status: 500, body: "Error sending request: #{e.message}")
    end
  end
  
  def signup(name, email, nickname, password)
    payload = { 
      user: { 
        name: name, 
        email: email, 
        nickname: nickname, 
        password: password 
      } 
    }
    response = send_request('signup', payload)
    handle_response(response)
  end
  
  def login(email, password)
    payload = { 
      auth_params: { 
        email: email, 
        password: password 
      } 
    }
    response = send_request('login', payload)
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

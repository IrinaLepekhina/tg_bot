#!/usr/bin/env ruby
# bin/update_env.rb

require 'faraday'
require 'json'
require 'uri'
require "fileutils"

# path to your application root.
APP_ROOT = File.expand_path("..", __dir__)

# Fetch the ngrok tunnels info
conn = Faraday.new(url: "http://172.17.0.1:4040")

max_retries = 10
retries = 0

data = nil

# Wait until ngrok is up and running
begin
  response = conn.get("/api/tunnels")
  data = JSON.parse(response.body)
  ngrok_url = data['tunnels'].find { |t| t['proto'] == 'https' }['public_url']
rescue
  retries += 1
  if retries < max_retries
    sleep 5
    retry
  else
    abort("Failed to fetch ngrok tunnel information after #{max_retries} retries.")
  end
end

hostname = URI.parse(ngrok_url).host

env_file_path = File.join(APP_ROOT, '.env.development')
env_content = File.read(env_file_path)

# Check and replace or append the NGROK_HOST value
if env_content =~ /NGROK_HOST='[^']*'/
  env_content.gsub!(/NGROK_HOST='[^']*'/, "NGROK_HOST='#{hostname}'")
else
  env_content = "NGROK_HOST='#{hostname}'\n#{env_content}"
end

# Write the updated content back to the file
File.write(env_file_path, env_content)
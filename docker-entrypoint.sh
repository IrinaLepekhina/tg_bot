#!/bin/sh
set -e

# 1. Update the .env file with the NGROK_HOST
ruby bin/update_env.rb

# 2. Load the updated .env values into the environment so that the next scripts and processes can access them
export $(cat .env.* | xargs)

# 3. Run the setup script which will setup the webhook and other things
./bin/setup

# 4. Remove any existing server PID file to ensure Rails server starts without issues
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# 5. Execute the main command (usually starting the Rails server)
exec "$@"

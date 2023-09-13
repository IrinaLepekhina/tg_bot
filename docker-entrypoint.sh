#!/bin/sh
set -e

# 1. Remove any existing server PID file to ensure Rails server starts without issues
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# 2. Execute the main command (usually starting the Rails server)
exec "$@"

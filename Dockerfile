# Dockerfile for a Ruby on Rails web application
FROM ruby:3.2
LABEL maintainer="iralepekhina@gmail.com"

# Allow apt to work with https-based sources
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends nodejs apt-transport-https redis-tools && \
    # Node setup
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=20 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -yqq && apt-get install nodejs -y && \
    # Ensure latest packages for Yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -yqq && apt-get install -yqq --no-install-recommends yarn

# Copy the Gemfile and Gemfile.lock into the image and install the gems
COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app
RUN gem install bundler --conservative && bundle install

# Copy the rest of the application code into the image
COPY . /usr/src/app/

# Set the entrypoint for the container
# Ensure Rails tmp/pids/server.pid was cleaned up
ENTRYPOINT ["./docker-entrypoint.sh"]

# Set the default command for the container
CMD ["bin/rails", "s", "-b", "0.0.0.0"]

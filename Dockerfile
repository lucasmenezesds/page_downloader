FROM ruby:3.2.2-slim-bullseye

# Common dependencies
RUN apt-get update -qq && apt-get install -yq --no-install-recommends  \
    build-essential \
    gnupg2 \
    curl \
    less \
    git \
    vim

# Create a directory for the app code
ENV APP_DIR=/app

RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR

# Upgrade RubyGems and install the latest Bundler version
RUN gem update --system && \
    gem install bundler -v 2.4.22


# Copy application code
COPY . .

# Install Gems
RUN bundle install

# Use Bash as the default command
CMD ["bin/docker-entry"]

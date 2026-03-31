FROM ruby:3.3-alpine

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm

WORKDIR /srv/jekyll

# Copy Gemfile first for better layer caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the site
COPY . .

# Build the Jekyll site
RUN bundle exec jekyll build

# Expose port
EXPOSE 4000

# Serve the site
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--port", "4000", "--skip-initial-build"]

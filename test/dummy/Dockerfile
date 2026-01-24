# syntax=docker/dockerfile:1
# check=error=true

# Build context is the project root (maquina_components/)
# Run: docker build -t maquina-components-demo -f test/dummy/Dockerfile .

ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libsqlite3-0 \
    libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Build stage for compiling gems and assets
FROM base AS build

# Install build packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libsqlite3-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy entire project (engine + dummy app)
COPY . .

# Install gems from project root (where Gemfile is)
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Change to dummy app directory for asset compilation
WORKDIR /rails/test/dummy

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Create engine CSS entry points and precompile assets
RUN mkdir -p app/assets/builds/tailwind && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails tailwindcss:engines && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Change to dummy app directory
WORKDIR /rails/test/dummy

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /rails/test/dummy/log /rails/test/dummy/tmp /rails/test/dummy/storage && \
    chown -R rails:rails /rails/test/dummy/log /rails/test/dummy/tmp /rails/test/dummy/storage

USER 1000:1000

# Entrypoint prepares the database
ENTRYPOINT ["./bin/docker-entrypoint"]

# Start server via Thruster on port 80
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]

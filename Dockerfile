# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Build and run by hand:
# docker build -t miniraise .
# docker run -d -p 3000:80 -e SECRET_KEY_BASE=<generate with bin/rails secret> -e FORCE_SSL=false \
#   -v miniraise-storage:/rails/storage --name miniraise miniraise

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.11
# Node, pinned to the same major version CI tests against (see .github/workflows/ci.yml).
# ARGs used in a FROM must be declared before the first FROM to stay in scope for later ones.
ARG NODE_VERSION=22

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 sqlite3 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Copied from the official image below instead of Debian's own nodejs/npm packages, which
# would float independently of what CI actually verified the frontend build against.
FROM docker.io/library/node:$NODE_VERSION-slim AS node

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/npm
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Install application gems
COPY vendor/* ./vendor/
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile

# Install Node packages
COPY package.json package-lock.json ./
RUN npm ci

# Copy application code
COPY . .

# This repo was first uploaded via the GitHub web UI, which does not preserve
# the executable bit on files. CLAUDE.md works around that by calling bin
# scripts as `ruby bin/foo` locally and in CI; the Dockerfile template calls
# ./bin/rails and ./bin/thrust directly (ENTRYPOINT + CMD too), so restore
# the bit here instead of touching the files in the repo.
RUN chmod +x bin/*

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY.
# Skip vite_ruby's own npm install so it reuses the node_modules installed above
# instead of running npm ci again and defeating the layer cache.
RUN SECRET_KEY_BASE_DUMMY=1 VITE_RUBY_SKIP_ASSETS_PRECOMPILE_INSTALL=true ./bin/rails assets:precompile

# Node and node_modules only exist in this build stage
RUN rm -rf node_modules

# Final stage for app image
FROM base

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy built artifacts: gems, application
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]

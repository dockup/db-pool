# ================================================================================
# Compile node assets as a separate stage
FROM node:9 AS staticassets

RUN apt-get update && apt-get install -y build-essential
RUN mkdir -p /db-pool/assets && mkdir -p /db-pool/priv
WORKDIR /db-pool/assets
COPY ./assets/package*.json ./
RUN npm install
COPY ./assets .
RUN ./node_modules/brunch/bin/brunch build --production

# ================================================================================
# Compile elixir app as a separate stage
FROM elixir:1.5.1-alpine AS application

# RUN apt-get update && apt-get install -y build-essential
RUN apk --update upgrade && apk add --no-cache build-base
RUN mix local.hex --force && mix local.rebar --force
RUN mkdir -p /db-pool
WORKDIR /db-pool
COPY mix.exs .
COPY mix.lock .
RUN mix deps.get --force --only prod
COPY . ./
COPY ./config/prod.secret.exs.example config/prod.secret.exs
COPY --from=staticassets /db-pool/priv/static ./priv/static

ENV MIX_ENV prod
RUN mix deps.get --only prod && \
    mix phx.digest && \
    mix release --env prod

# ================================================================================
# Start from alpine and copy binaries
FROM alpine:3.8
MAINTAINER Codemancers <team@codemancers.com>

RUN apk add --no-cache bash libssl1.0 openssh mysql-client postgresql postgresql-contrib
COPY --from=application /db-pool/_build /db-pool/_build

ENV MIX_ENV prod
ENV PORT 4000

EXPOSE 4000
CMD /db-pool/_build/prod/rel/db_pool/bin/db_pool foreground

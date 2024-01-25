#!/bin/sh

[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

./nakama-3.20.0-darwin-arm64/nakama migrate up \
  --database.address ${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}

./nakama-3.20.0-darwin-arm64/nakama \
  --config ./nakama.yml \
  --name nakama1 \
  --database.address ${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB} \
  --logger.level DEBUG \
  --session.token_expiry_sec 7200 \
  --metrics.prometheus_port 9100
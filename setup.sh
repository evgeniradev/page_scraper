#!/bin/sh

BUILD_COMMANDS="
  mix deps.get && \
  mix deps.compile && \
  mix ecto.drop && \
  mix ecto.create && \
  mix ecto.migrate && \
  cd assets && \
  npm install && \
  exit"

docker-compose stop page_scraper_postgres page_scraper_app page_scraper_chrome
docker-compose build
docker-compose run --rm page_scraper_app sh -c "$BUILD_COMMANDS"

FROM elixir:1.9.1-alpine
RUN mkdir /page_scraper
COPY . /page_scraper
WORKDIR /page_scraper
RUN apk update
RUN apk upgrade
RUN apk add --no-cache tzdata inotify-tools nodejs npm
RUN mix local.hex --force
RUN mix local.rebar --force
CMD ["mix", "phx.server"]

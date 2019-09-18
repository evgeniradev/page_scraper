use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :page_scraper, PageScraperWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :page_scraper, PageScraper.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "page_scraper_test",
  hostname: "page_scraper_postgres",
  pool: Ecto.Adapters.SQL.Sandbox

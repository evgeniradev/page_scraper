defmodule PageScraperWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox, as: EctoSQLSandbox

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import PageScraperWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint PageScraperWeb.Endpoint
    end
  end

  setup tags do
    :ok = EctoSQLSandbox.checkout(PageScraper.Repo)
    unless tags[:async] do
      EctoSQLSandbox.mode(PageScraper.Repo, {:shared, self()})
    end
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end

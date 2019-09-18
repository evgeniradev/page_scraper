defmodule PageScraper.Scraper.ChangeDetectorInitializer do
  @moduledoc """
  Destroys old WebDriver sessions and starts ChangeDetector workers.
  """

  use GenServer

  alias PageScraper.Scraper.ContentFetcher
  alias PageScraper.Scraper.Manager

  @impl true
  def init(state) do
    GenServer.cast(__MODULE__, :manage)

    {:ok, state}
  end

  @impl true
  def handle_cast(:manage, state) do
    destroy_sessions()
    ContentFetcher.start_session()
    Manager.start_all_change_detector_children()

    {:noreply, state}
  end

  def child_spec(_) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}}
  end

  def start_link do
    GenServer.start_link(__MODULE__, __MODULE__, name: __MODULE__)
  end

  defp session_ids do
    sessions = Hound.Session.active_sessions()

    if is_tuple(sessions), do: raise_error()

    Enum.map(sessions, fn session -> session["id"] end)
  end

  defp destroy_sessions do
    session_ids()
    |> Enum.each(fn session_id -> Hound.Session.destroy_session(session_id) end)
  end

  def raise_error do
    raise "WebDriver is unreachable."
  end
end

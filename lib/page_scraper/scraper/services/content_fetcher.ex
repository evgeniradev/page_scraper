defmodule PageScraper.Scraper.ContentFetcher do
  @moduledoc """
  Fetches the page source for a given URL.
  """

  use GenServer

  alias Hound.Helpers.Navigation, as: HoundNavigation
  alias Hound.Helpers.Page, as: HoundPage

  defdelegate raise_error(), to: PageScraper.Scraper.ChangeDetectorInitializer

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:fetch, url, css_selector, text_only}, _from, state) do
    content =
      if url do
        IO.puts("Fetching: #{url}")

        if is_tuple(HoundNavigation.navigate_to(url)), do: raise_error()

        tmp =
          HoundPage.page_source()
          |> Floki.find(css_selector)
          |> Floki.raw_html()

        if text_only, do: Floki.text(tmp), else: tmp
      end

    {:reply, content, state}
  end

  @impl true
  def handle_call(:start_session, _from, state) do
    Hound.start_session()

    {:reply, :ok, state}
  end

  def child_spec(_) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}}
  end

  def start_link do
    GenServer.start_link(__MODULE__, __MODULE__, name: __MODULE__)
  end

  def fetch(url, css_selector, text_only) do
    GenServer.call(__MODULE__, {:fetch, url, css_selector, text_only}, :infinity)
  end

  def start_session do
    GenServer.call(__MODULE__, :start_session)
  end
end

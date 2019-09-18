defmodule PageScraper.Scraper.ChangeDetector do
  @moduledoc """
  Detects page changes and logs them as PageChange records.
  """

  use GenServer

  import PageScraper.Scraper

  alias PageScraper.Scraper.ContentFetcher

  @impl true
  def init(page_id) do
    GenServer.cast(self(), :detect_change)

    {:ok, page_id}
  end

  @impl true
  def handle_cast(:detect_change, page_id) do
    detect_change(page_id)

    {:noreply, page_id}
  end

  def child_spec(page_id) do
    %{id: page_id, start: {__MODULE__, :start_link, [page_id]}}
  end

  def start_link(page_id) do
    GenServer.start_link(__MODULE__, page_id)
  end

  defp detect_change(page_id) do
    page = get_page!(page_id)
    page_change = get_page_latest_page_change(page)
    content = ContentFetcher.fetch(page.url, page.css_selector, page.text_only)

    unless page_change, do: create_page_change!(page, %{content: content})

    if page_change && "#{page_change.content}" != "#{content}" do
      IO.puts("Change detected: #{page.url}")
      delete_page_exessive_page_changes(page)
      create_page_change!(page, %{content: content})
    end

    Process.sleep(page.polling_frequency)

    detect_change(page_id)
  end
end

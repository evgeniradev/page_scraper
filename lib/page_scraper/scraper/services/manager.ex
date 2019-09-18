defmodule PageScraper.Scraper.Manager do
  @moduledoc """
  The Supervisor for the ChangeDetectorInitializer, ContentFetcher and ChangeDetector workers.
  """

  alias PageScraper.Scraper
  alias PageScraper.Scraper.ChangeDetector
  alias PageScraper.Scraper.ChangeDetectorInitializer
  alias PageScraper.Scraper.ContentFetcher

  def start_link do
    # Ensures the main application does not crash if this Supervisor does too often.
    Process.sleep(3000)

    Supervisor.start_link(children(), strategy: :one_for_all, name: __MODULE__)
  end

  def alive? do
    Supervisor.which_children(PageScraper.Supervisor)
    |> Enum.find_value(fn worker ->
      Tuple.to_list(worker)
      |> List.first == __MODULE__
    end)
  end

  def start_all_change_detector_children do
    Scraper.list_live_pages()
    |> Enum.map(fn page -> start_change_detector_child(page) end)
  end

  def start_change_detector_child(page) do
   Supervisor.start_child(__MODULE__, ChangeDetector.child_spec(page.id))
  end

  def terminate_change_detector_child(page) do
    Supervisor.terminate_child(__MODULE__, page.id)
    Supervisor.delete_child(__MODULE__, page.id)
  end

  defp children do
    [ContentFetcher, ChangeDetectorInitializer]
  end
end

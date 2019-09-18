defmodule PageScraper.Scraper.PageChange do
  @moduledoc """
  The model for PageChange records.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @timestamps_opts [type: Timex.Ecto.TimestampWithTimezone,
                    autogenerate: {Timex.Ecto.TimestampWithTimezone, :autogenerate, []}]

  schema "page_changes" do
    field :content, :string

    belongs_to :page, PageScraper.Scraper.Page

    timestamps()
  end

  @doc false
  def changeset(page_change, attrs) do
    page_change |> cast(attrs, [:content])
  end
end

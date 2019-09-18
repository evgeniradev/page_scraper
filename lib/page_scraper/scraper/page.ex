defmodule PageScraper.Scraper.Page do
  @moduledoc """
  The model for Page records.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @timestamps_opts [type: Timex.Ecto.TimestampWithTimezone,
                  autogenerate: {Timex.Ecto.TimestampWithTimezone, :autogenerate, []}]

  schema "pages" do
    field :name, :string
    field :url, :string
    field :css_selector, :string
    field :live, :boolean
    field :text_only, :boolean
    field :polling_frequency, :integer

    has_many :page_changes, PageScraper.Scraper.PageChange, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :url, :css_selector, :live, :text_only, :polling_frequency])
    |> validate_required([:name, :url, :css_selector, :polling_frequency])
    |> validate_format(:url, ~r/^http(s)?:\/\/.*/, message: "HTTP protocol must be included.")
  end
end

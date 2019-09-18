defmodule PageScraper.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :name, :string
      add :url, :text
      add :css_selector, :string
      add :live, :boolean
      add :text_only, :boolean
      add :polling_frequency, :integer

      timestamps(type: :timestamptz)
    end

  end
end

defmodule PageScraper.Repo.Migrations.CreatePageChanges do
  use Ecto.Migration

  def change do
    create table(:page_changes) do
      add :content, :text
      add :page_id, references(:pages, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:page_changes, [:page_id])
  end
end

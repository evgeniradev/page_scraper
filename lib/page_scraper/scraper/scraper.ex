defmodule PageScraper.Scraper do
  @moduledoc """
  The Scraper context.
  """

  import Ecto.Query, warn: false
  import System, only: [get_env: 1]

  alias PageScraper.Repo
  alias PageScraper.Scraper.ContentFetcher
  alias PageScraper.Scraper.Manager
  alias PageScraper.Scraper.Page
  alias PageScraper.Scraper.PageChange

  @doc """
  Gets the latest page_change that belongs to a given page.

  ## Examples

      iex> get_page_latest_page_change!(%Page{})
      %PageChange{}

  """
  def get_page_latest_page_change(page) do
    query = from(c in PageChange, order_by: c.inserted_at, limit: 1)
    page = Repo.preload(page, page_changes: query)

    List.first(page.page_changes)
  end

  @doc """
  Deletes exessive page_changes that belong to a given page.

  ## Examples

      iex> delete_page_exessive_page_changes!(%Page{})
      :ok

  """
  def delete_page_exessive_page_changes(page) do
    query = from(c in PageChange, where: c.page_id == ^page.id)
    count = Repo.aggregate(query, :count, :id)
    env_limit = get_env("PAGE_CHANGES_LIMIT")
    limit = if is_nil(env_limit), do: 100, else: String.to_integer(env_limit)

    if count >= limit do
      delete_page_oldest_page_change(page)
      delete_page_exessive_page_changes(page)
    end

    :ok
  end

  @doc """
  Deletes the oldest page_change that belongs to a given page.

  ## Examples

      iex> delete_page_oldest_page_change!(%Page{})
      %PageChange{}

  """
  def delete_page_oldest_page_change(page) do
    if page_change = get_page_oldest_page_change(page) do
      Repo.delete!(page_change)
    end
  end

  @doc """
  Gets the oldest page_change that belongs to a given page.

  ## Examples

      iex> get_page_oldest_page_change!(%Page{})
      %PageChange{}

  """
  def get_page_oldest_page_change(page) do
    query = from(
      c in PageChange,
      order_by: :inserted_at,
      where: c.page_id == ^page.id,
      limit: 1
    )

    Repo.all(query)
    |> List.first
  end

  @doc """
  Returns the list of live pages.

  ## Examples

      iex> list_live_pages()
      [%Page{}, ...]

  """
  def list_live_pages do
    Repo.all(from(p in Page, where: p.live == true))
  end

  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages do
    Repo.all(from(p in Page, order_by: [desc: p.live]))
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(id) do
    Repo.get!(Page, id)
    |> Repo.preload(page_changes: from(c in PageChange, order_by: [desc: c.inserted_at]))
  end

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(%{field: value})
      {:ok, %Page{}}

      iex> create_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(attrs \\ %{}) do
    {status, page} = %Page{} |> Page.changeset(attrs) |> Repo.insert()

    if status == :ok && Manager.alive? do
      try do
        content = ContentFetcher.fetch(attrs["url"], attrs["css_selector"], attrs["text_only"])

        create_page_change!(page, %{content: content})
      catch
        :exit, _ -> IO.puts("Error: Initial PageChange not created.")
      end

      if page.live, do: Manager.start_change_detector_child(page)
    end

    {status, page}
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Page{} = page, attrs) do
    {status, page} = Page.changeset(page, attrs) |> Repo.update()

    if status == :ok && Manager.alive? do
      if page.live do
        Manager.start_change_detector_child(page)
      else
        Manager.terminate_change_detector_child(page)
      end
    end

    {status, page}
  end

  @doc """
  Deletes a Page.

  ## Examples

      iex> delete_page(page)
      {:ok, %Page{}}

      iex> delete_page(page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(%Page{} = page) do
    if Manager.alive?, do: Manager.terminate_change_detector_child(page)

    Repo.delete(page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(page)
      %Ecto.Changeset{source: %Page{}}

  """
  def change_page(%Page{} = page) do
    Page.changeset(page, %{})
  end

  alias PageScraper.Scraper.PageChange

  @doc """
  Returns the list of page_changes.

  ## Examples

      iex> list_page_changes()
      [%PageChange{}, ...]

  """
  def list_page_changes do
    Repo.all(PageChange)
  end

  @doc """
  Gets a single page_change.

  Raises `Ecto.NoResultsError` if the Page change does not exist.

  ## Examples

      iex> get_page_change!(123)
      %PageChange{}

      iex> get_page_change!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page_change!(id), do: Repo.get!(PageChange, id)

  @doc """
  Creates a page_change.

  ## Examples

      iex> create_page_change!(page, %{field: value})
      %PageChange{}

  """
  def create_page_change!(page, attrs \\ %{}) do
    Ecto.build_assoc(page, :page_changes)
    |> PageChange.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a page_change.

  ## Examples

      iex> update_page_change!(page_change, %{field: new_value})
      %PageChange{}

  """
  def update_page_change!(%PageChange{} = page_change, attrs) do
    page_change
    |> PageChange.changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Deletes a PageChange.

  ## Examples

      iex> delete_page_change!(page_change)
      %PageChange{}

  """
  def delete_page_change!(%PageChange{} = page_change) do
    Repo.delete!(page_change)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page_change changes.

  ## Examples

      iex> change_page_change(page_change)
      %Ecto.Changeset{source: %PageChange{}}

  """
  def change_page_change(%PageChange{} = page_change) do
    PageChange.changeset(page_change, %{})
  end
end

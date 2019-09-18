defmodule PageScraperWeb.PageController do
  use PageScraperWeb, :controller

  import PageScraperWeb.PageHelper

  alias PageScraper.Scraper
  alias PageScraper.Scraper.Page

  def index(conn, _params) do
    pages = Scraper.list_pages()
    render(conn, "index.html", pages: pages)
  end

  def new(conn, _params) do
    changeset = Scraper.change_page(%Page{})

    render(
      conn,
      "new.html",
      changeset: changeset,
      polling_frequency_options: polling_frequency_options()
    )
  end

  def create(conn, %{"page" => page_params}) do
    case Scraper.create_page(page_params) do
      {:ok, page} ->
        conn
        |> put_flash(:info, "Page created successfully.")
        |> redirect(to: page_path(conn, :show, page))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          polling_frequency_options: polling_frequency_options()
        )
    end
  end

  def show(conn, %{"id" => id}) do
    page = Scraper.get_page!(id)
    render(conn, "show.html", page: page)
  end

  def edit(conn, %{"id" => id}) do
    page = Scraper.get_page!(id)
    changeset = Scraper.change_page(page)
    render(
      conn,
      "edit.html",
      page: page,
      changeset: changeset,
      polling_frequency_options: polling_frequency_options()
    )
  end

  def update(conn, %{"id" => id, "page" => page_params}) do
    page = Scraper.get_page!(id)

    case Scraper.update_page(page, page_params) do
      {:ok, page} ->
        conn = put_flash(conn, :info, "Page updated successfully.")

        if page_params["url"] do
          redirect(conn, to: page_path(conn, :show, page))
        else
          redirect(conn, to: page_path(conn, :index))
        end
      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          page: page,
          changeset: changeset,
          polling_frequency_options: polling_frequency_options()
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    page = Scraper.get_page!(id)
    {:ok, _page} = Scraper.delete_page(page)

    conn
    |> put_flash(:info, "Page deleted successfully.")
    |> redirect(to: page_path(conn, :index))
  end
end

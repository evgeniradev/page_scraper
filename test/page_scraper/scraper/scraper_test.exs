defmodule PageScraper.ScraperTest do
  use PageScraper.DataCase

  alias PageScraper.Scraper

  describe "pages" do
    alias PageScraper.Scraper.Page

    @valid_attrs %{
      name: "some name",
      url: "http://localhost",
      css_selector: "body",
      live: false,
      text_only: false,
      polling_frequency: 1000
    }

    @update_attrs %{
      name: "some updated name",
      url: "https://localhost",
      css_selector: "html",
      live: false,
      text_only: true,
      polling_frequency: 2000
    }

    @invalid_attrs %{
      name: nil,
      url: nil,
      css_selector: nil,
      polling_frequency: nil
    }

    def page_fixture(attrs \\ %{}) do
      {:ok, page} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Scraper.create_page()

      page
    end

    test "list_pages/0 returns all pages" do
      page = page_fixture()
      assert Scraper.list_pages() == [page]
    end

    test "get_page!/1 returns the page with given id" do
      page = page_fixture()
      assert Scraper.get_page!(page.id).id == page.id
    end

    test "create_page/1 with valid data creates a page" do
      assert {:ok, %Page{} = page} = Scraper.create_page(@valid_attrs)
      assert page.name == "some name"
      assert page.url == "http://localhost"
      assert page.css_selector == "body"
      assert page.live == false
      assert page.text_only == false
      assert page.polling_frequency == 1000
    end

    test "create_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scraper.create_page(@invalid_attrs)
    end

    test "update_page/2 with valid data updates the page" do
      page = page_fixture()
      assert {:ok, page} = Scraper.update_page(page, @update_attrs)
      assert %Page{} = page
      assert page.name == "some updated name"
      assert page.url == "https://localhost"
      assert page.css_selector == "html"
      assert page.live == false
      assert page.text_only == true
      assert page.polling_frequency == 2000
    end

    test "update_page/2 with invalid data returns error changeset" do
      page = page_fixture()
      assert {:error, %Ecto.Changeset{}} = Scraper.update_page(page, @invalid_attrs)
      assert page.name == Scraper.get_page!(page.id).name
    end

    test "delete_page/1 deletes the page" do
      page = page_fixture()
      assert {:ok, %Page{}} = Scraper.delete_page(page)
      assert_raise Ecto.NoResultsError, fn -> Scraper.get_page!(page.id) end
    end

    test "change_page/1 returns a page changeset" do
      page = page_fixture()
      assert %Ecto.Changeset{} = Scraper.change_page(page)
    end
  end

  describe "page_changes" do
    @valid_attrs %{content: "some content"}
    @update_attrs %{content: "some updated content"}

    def page_change_fixture(attrs \\ %{}) do
      page = page_fixture() |> Repo.preload(:page_changes)
      List.first(page.page_changes) |> Scraper.delete_page_change!()

      attrs = attrs |> Enum.into(@valid_attrs)

      Scraper.create_page_change!(page, attrs)
    end

    test "list_page_changes/0 returns all page_changes" do
      page_change = page_change_fixture()
      assert Scraper.list_page_changes() == [page_change]
    end

    test "get_page_change!/1 returns the page_change with given id" do
      page_change = page_change_fixture()
      assert Scraper.get_page_change!(page_change.id) == page_change
    end

    test "create_page_change/1 with valid data creates a page_change" do
      page_change = Scraper.create_page_change!(page_fixture(), @valid_attrs)
      assert page_change.content == "some content"
    end

    test "update_page_change/2 with valid data updates the page_change" do
      page_change = Scraper.update_page_change!(page_change_fixture(), @update_attrs)
      assert page_change.content == "some updated content"
    end

    test "delete_page_change/1 deletes the page_change" do
      page_change = page_change_fixture()
      Scraper.delete_page_change!(page_change)
      assert_raise Ecto.NoResultsError, fn -> Scraper.get_page_change!(page_change.id) end
    end

    test "change_page_change/1 returns a page_change changeset" do
      page_change = page_change_fixture()
      assert %Ecto.Changeset{} = Scraper.change_page_change(page_change)
    end
  end
end

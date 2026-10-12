require "test_helper"

class PaginationRenderTest < ActiveSupport::TestCase
  def view
    @view ||= ApplicationController.new.view_context
  end

  test "ellipsis hides only its glyph so the label is announced" do
    html = view.render("components/pagination/ellipsis")
    wrapper = html[/<span[^>]*data-pagination-part="ellipsis"[^>]*>/]

    refute_includes wrapper, "aria-hidden"
    assert_match(/<svg[^>]*aria-hidden="true"/, html)
    assert_includes html, %(<span class="sr-only">More pages</span>)
  end

  test "ellipsis merges caller data" do
    html = view.render("components/pagination/ellipsis", data: {testid: "gap"}, id: "gap")

    assert_includes html, %(data-testid="gap")
    assert_includes html, %(data-pagination-part="ellipsis")
    assert_includes html, %(id="gap")
  end

  test "disabled previous and next merge caller data" do
    previous = view.render("components/pagination/previous", disabled: true, data: {testid: "prev"})
    following = view.render("components/pagination/next", data: {testid: "next"})

    assert_includes previous, %(data-testid="prev")
    assert_includes previous, %(data-pagination-part="previous")
    assert_includes previous, %(aria-disabled="true")
    assert_includes following, %(data-testid="next")
    assert_includes following, %(data-pagination-part="next")
    assert_includes following, %(aria-disabled="true")
  end

  test "link emits data-active only when active" do
    active = view.render("components/pagination/link", href: "/p/2", active: true) { "2" }
    inactive = view.render("components/pagination/link", href: "/p/3") { "3" }

    assert_includes active, %(data-active="true")
    assert_includes active, %(aria-current="page")
    refute_includes inactive, "data-active"
    refute_includes inactive, "aria-current"
  end
end

class PaginationHelperTest < ActionView::TestCase
  include MaquinaComponents::ComponentsHelper
  include MaquinaComponents::PaginationHelper

  # Pagy <= 9: vars[:page_param] (Symbol), prev, public series.
  LegacyPagy = Struct.new(:page, :pages, :prev, :next, :vars, keyword_init: true) do
    def series = [1, "2", 3, :gap, 9]
  end

  # Pagy >= 43: options[:page_key] (String), previous, protected series.
  CurrentPagy = Struct.new(:page, :pages, :previous, :next, :options, keyword_init: true) do
    protected

    def series = [1, "2", 3, :gap, 9]
  end

  def items_path(params = {}) = "/items?#{params.to_query}"

  test "paginated_path reads page_param on Pagy 9 and older" do
    pagy = LegacyPagy.new(page: 2, pages: 9, prev: 1, next: 3, vars: {page_param: :p})

    assert_equal "/items?p=3", paginated_path(:items_path, pagy, 3)
  end

  test "paginated_path reads page_key on Pagy 43" do
    pagy = CurrentPagy.new(page: 2, pages: 9, previous: 1, next: 3, options: {page_key: "pg"})

    assert_equal "/items?pg=3", paginated_path(:items_path, pagy, 3)
  end

  test "paginated_path falls back to page and keeps the other query params" do
    request.query_parameters.merge!("q" => "x", "page" => "1")
    pagy = CurrentPagy.new(page: 2, pages: 9, previous: 1, next: 3, options: {})

    assert_equal "/items?page=3&q=x", paginated_path(:items_path, pagy, 3)
  end

  test "pagination_nav renders with either Pagy API" do
    legacy = LegacyPagy.new(page: 2, pages: 9, prev: 1, next: 3, vars: {})
    current = CurrentPagy.new(page: 2, pages: 9, previous: 1, next: 3, options: {})

    [legacy, current].each do |pagy|
      html = pagination_nav(pagy, :items_path)

      assert_includes html, %(href="/items?page=1")
      assert_includes html, %(data-active="true")
      assert_includes html, %(data-pagination-part="ellipsis")
      assert_includes html, %(href="/items?page=3")
    end
  end
end
